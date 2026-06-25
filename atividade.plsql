SET SERVEROUTPUT ON;

-- Limpeza prévia das tabelas
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Alocacao CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Projeto CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Consultor CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Departamento CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

-- Criação das Tabelas
CREATE TABLE Departamento (
    id_depto NUMBER PRIMARY KEY,
    nome     VARCHAR2(50) NOT NULL,
    orcamento NUMBER(12,2) NOT NULL
);

CREATE TABLE Consultor (
    id_consultor NUMBER PRIMARY KEY,
    nome         VARCHAR2(100) NOT NULL,
    nivel        VARCHAR2(20) NOT NULL, -- 'Junior', 'Pleno', 'Senior'
    salario_base NUMBER(10,2) NOT NULL,
    id_depto     NUMBER NOT NULL,
    CONSTRAINT fk_consultor_depto FOREIGN KEY (id_depto) REFERENCES Departamento(id_depto)
);

CREATE TABLE Projeto (
    id_projeto    NUMBER PRIMARY KEY,
    nome          VARCHAR2(100) NOT NULL,
    data_inicio   DATE NOT NULL,
    data_fim      DATE,
    status        VARCHAR2(20) DEFAULT 'Planejado' NOT NULL -- 'Planejado', 'Em Andamento', 'Concluido'
);

CREATE TABLE Alocacao (
    id_consultor NUMBER,
    id_projeto   NUMBER,
    horas_alocadas NUMBER NOT NULL,
    CONSTRAINT pk_alocacao PRIMARY KEY (id_consultor, id_projeto),
    CONSTRAINT fk_aloc_consultor FOREIGN KEY (id_consultor) REFERENCES Consultor(id_consultor),
    CONSTRAINT fk_aloc_projeto FOREIGN KEY (id_projeto) REFERENCES Projeto(id_projeto)
);

-- Inserção de Dados
INSERT INTO Departamento VALUES (10, 'Desenvolvimento', 500000.00);
INSERT INTO Departamento VALUES (20, 'Data Science', 350000.00);

INSERT INTO Consultor VALUES (1, 'Ana Costa', 'Senior', 9500.00, 10);
INSERT INTO Consultor VALUES (2, 'Bruno Melo', 'Pleno', 6000.00, 10);
INSERT INTO Consultor VALUES (3, 'Carla Dias', 'Junior', 3500.00, 20);
INSERT INTO Consultor VALUES (4, 'Daniel Silva', 'Senior', 11000.00, 20);

INSERT INTO Projeto VALUES (101, 'Sistema CRM', TO_DATE('01/01/2026', 'DD/MM/YYYY'), NULL, 'Em Andamento');
INSERT INTO Projeto VALUES (102, 'Pipeline de Dados', TO_DATE('15/02/2026', 'DD/MM/YYYY'), NULL, 'Em Andamento');
INSERT INTO Projeto VALUES (103, 'Portal RH', TO_DATE('01/05/2026', 'DD/MM/YYYY'), TO_DATE('01/06/2026', 'DD/MM/YYYY'), 'Concluido');

COMMIT;

CREATE OR REPLACE FUNCTION calcular_custo_consultor (
    p_idConsultor IN Consultor.id_consultor%TYPE,
    p_horasAlocadas IN NUMBER
) RETURN NUMBER
IS
    v_SalarioBase Consultor.salario_base%TYPE;
    v_valor_hora NUMBER;
    v_custo_total NUMBER;
BEGIN
    
    select salario_base 
    into v_SalarioBase
    from Consultor
    where id_consultor = p_idConsultor;

    v_valor_hora := v_SalarioBase/160;

    v_custo_total := p_horasAlocadas * v_valor_hora;


    RETURN v_custo_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Tratamento se não achar nada
    WHEN OTHERS THEN
        RETURN NULL; -- Tratamento genérico de erro
END;
/

CREATE OR REPLACE PROCEDURE alocar_consultor(
    p_idConsultor in Consultor.id_consultor%TYPE,
    p_idProjeto in Projeto.id_projeto%TYPE,
    p_horasAlocadas in Alocacao.horas_alocadas%TYPE
)
IS
    v_status in Projeto.status%TYPE;

BEGIN
        select status into v_status from Projeto 
        where p_idProjeto = id_projeto;
        
        if v_status == 'Concluido' then
            raise_application_error(-20001,'Não é possível alocar consultores em projetos concluídos')
        end if;
        
        insert into Alocacao(id_consultor, id_projeto, horas_alocadas)values(p_idConsultor, p_idProjeto,p_horasAlocadas);

        dbms_output.put_line('O Consultor foi alocado!');
EXCEPTION

    when NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Projeto não encontrado.');
    when DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Este consultor já está alocado neste projeto.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLERRM);
END alocar_consultor;
/