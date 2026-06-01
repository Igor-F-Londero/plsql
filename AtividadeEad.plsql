CREATE TABLE Departamento(
    cod_dep NUMBER PRIMARY KEY,
    nome    VARCHAR(100) NOT NULL

);

CREATE TABLE Projetos(
    cod_proj NUMBER PRIMARY KEY,
    nome     VARCHAR(100) NOT NULL,
    duracao  NUMBER NOT NULL

-- restrição definida para o banco de dados só criar projetos com duração acima de 0
    CONSTRAINT ck_projetos_duracao CHECK (duracao > 0)

);


CREATE TABLE Funcionarios(
    cod_func NUMBER PRIMARY KEY,
    nome     VARCHAR(100) NOT NULL,
    cod_dep_r  NUMBER NOT NULL,
    numero_proj NUMBER DEFAULT 0 NOT NULL,
    numero_dep NUMBER DEFAULT 0 NOT NULL,

    CONSTRAINT  fk_funcionarios_departamento
        FOREIGN KEY (codigo_dep_r)
        REFERENCES Departamento(cod_dep),

    CONSTRAINT ck_funcionarios_num_proj
        CHECK (numero_proj >= 0),

    CONSTRAINT ck_funcionarios_num_dependentes
        CHECK (numero_dep >= 0)

);

CREATE TABLE Dependentes(
    cod_depen NUMBER PRIMARY KEY,
    nome      VARCHAR2(100) NOT NULL,
    cod_func_r NUMBER NOT NULL,

    CONSTRAINT fk_dependentes_funcionarios
    FOREIGN KEY (cod_func_r)
    REFERENCES Funcionarios (cod_func)
);


CREATE TABLE FuncionariosProjetos(
    cod_func_r NUMBER NOT NULL,
    cod_proj_r  NUMBER NOT NULL,
    horas_alocadas NUMBER NOT NULL,

    CONSTRAINT pk_fp_funcionarios
        PRIMARY KEY (cod_func_r, cod_proj_r),
        
    CONSTRAINT fk_fp_funcionarios
        PRIMARY KEY(cod_func_r)
        REFERENCES Funcionarios (cod_func),

    CONSTRAINT fk_fp_projetos
        FOREIGN KEY (cod_proj_r)
        REFERENCES Projetos (cod_proj),

    CONSTRAINT ck_fp_horas
        CHECK (horas_alocadas > 0)

);

--sequence

CREATE SEQUENCE seq_dep
START WITH 1
INCREMENT BY 1;

CREATE  SEQUENCE seq_proj
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE seq_func
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE seq_depen
START WITH 1
INCREMENT BY 1;

--procedures


--a) incluiProjeto (nome, duração)

CREATE OR REPLACE PROCEDURE incluirProjeto(
    p_nome IN Projetos.nome%TYPE,
    p_duracao IN Projetos.duracao%TYPE
)
IS
 BEGIN
    IF p_duracao IS NULL OR  p_duracao <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'A duracao do projeto deve ser maior que zero');
    END IF;

    INSERT INTO Projetos(cod_proj,nome,duracao)VALUES (seq_proj.NEXTVAL,p_nome,p_duracao);
 END;
 /

--b) incluiFuncionario (nome, codigodepartamento)
CREATE OR REPLACE PROCEDURE incluirFuncionario(
    p_nome      IN Funcionarios.nome%TYPE,
    p_cod_dep_r IN Funcionarios.cod_dep_r%TYPE
)    
IS
    v_existe NUMBER;
 BEGIN
    -- Antes de inserir o funcionario, verificamos se o departamento existe.
    SELECT COUNT(*) INTO v_existe FROM Departamento WHERE cod_dep = p_cod_dep_r;

    IF v_existe = 0 THEN 
        RAISE_APPLICATION_ERROR(-20002,'Departamento informado não existe');
    END IF;

    INSERT INTO Funcionarios (cod_func,nome,cod_dep_r,numero_proj,numero_dep)
    VALUES (seq_func.NEXTVAL,p_nome,p_cod_dep_r,0,0);

 END;
 /


-- c) incluiDependente (nome, codigoFuncionario)
CREATE OR REPLACE PROCEDURE incluiDependente(
    p_nome IN Dependentes.nome%TYPE,
    p_cod_func_r IN Dependentes.cod_func_r%TYPE
)
IS
    v_existe NUMBER;
 BEGIN
    --verifica primeiro se o funcionario existe
    SELECT COUNT(*) INTO v_existe FROM Funcionarios WHERE cod_func = p_cod_func_r;
        
        IF v_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Funcionário informado não existe');
        END IF;

    INSERT INTO Dependentes(cod_depen,nome,cod_func_r)VALUES (seq_depen.NEXTVAL,p_nome,p_cod_func_r);
    
    --regra
    UPDATE Funcionarios SET  numero_dep = numero_dep +1 WHERE cod_func = p_cod_func_r;
END;
/

--d) incluiParticipacao (codigoFuncionario, codigoProjeto, horas)
CREATE OR REPLACE PROCEDURE incluiParticipacao(
    p_cod_func IN Funcionarios.cod_func%TYPE,
    p_cod_proj IN Projetos.cod_proj%TYPE,
    p_horas IN FuncionariosProjetos.horas_alocadas%TYPE
)
IS
    v_existe_func NUMBER;
    v_existe_proj NUMBER;
    v_existe_total_horas NUMBER;
 BEGIN
    IF p_horas IS NULL OR p_horas <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004,'As horas alocadas devem ser maior que zero.');
    END IF;

    --verifica se funcionario existe

    SELECT COUNT(*) INTO v_existe_func FROM Funcionarios WHERE cod_func = p_cod_func;

    IF v_existe_func = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Funcionario informado não existe');
    END IF;
    -- verifica se projeto existe
    SELECT COUNT(*) INTO v_existe_proj FROM Projetos WHERE cod_proj = p_cod_proj;

    IF v_existe_proj = 0 THEN
        RAISE_APPLICATION_ERROR(-20006,'Projeto não existe');
    END IF;

    --soma as horas que o funcionario possui em projetos

    SELECT NVL(SUM(horas_alocadas),0) INTO v_existe_total_horas FROM FuncionariosProjetos WHERE cod_func_r = p_cod_func;


    --regra
    IF v_existe_total_horas + p_horas > 40 THEN
        RAISE_APPLICATION_ERROR(-20007,'ERRO: Maximo de horas registradas em projetos!.');
    END IF;

    INSERT INTO FuncionariosProjetos(cod_func_r,cod_proj_r,horas_alocadas)VALUES(p_cod_func,p_cod_proj,p_horas);

    --regra
    UPDATE Funcionarios
    SET numero_proj = numero_proj + 1
    WHERE cod_func = p_cod_func;
END;
/

--funções


-- 1) Total de horas trabalhadas por um funcionario.
CREATE OR REPLACE FUNCTION totalHorasFuncionario(p_cod_func IN Funcionario.cod_func%TYPE) RETURN NUMBER 
IS
    v_existe NUMBER;
    v_existe_total_horas NUMBER;
 BEGIN
    SELECT COUNT(*) INTO v_existe FROM Funcionarios WHERE cod_func = p_cod_func;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20008,'Funcionario não existe');
    END IF;

    SELECT NVL(SUM(horas_alocadas),0) INTO v_existe_total_horas FROM FuncionariosProjetos WHERE cod_func = p_cod_func;

    RETURN v_existe_total_horas;
 END;
/

--2)Numero de dependentes de um funcionario.
CREATE OR REPLACE FUNCTION numeroDependentesFuncionario(p_cod_func IN Funcionarios.cod_func%TYPE ) RETURN NUMBER
IS
    v_numero_dependentes NUMBER;
 BEGIN

    SELECT numero_dep INTO v_numero_dependentes FROM Funcionarios WHERE cod_func = p_cod_func;

    RETURN v_numero_dependentes;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009,'Funcionario informado não existe');
 END;
/

-- 3) Dados de um determinado projeto.
CREATE OR REPLACE FUNCTION dadosProjeto(
    p_cod_proj IN Projetos.cod_proj%TYPE) RETURN VARCHAR2
IS
    v_dados VARCHAR2(300);
 BEGIN
    SELECT 'Codigo: ' || cod_proj ||
            ' | Nome: ' || nome ||
            ' | Duracao: ' || duracao
    INTO v_dados
    FROM Projetos WHERE cod_proj = p_cod_proj;

    RETURN v_dados;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Projeto informado não existe.');
 END;
/

-- 4) Numero de projetos em que um departamento participa.
CREATE OR REPLACE FUNCTION numeroProjetosDepartamento(p_cod_dep IN Departamento.cod_dep%TYPE) RETURN NUMBER
IS
    v_existe NUMBER;
    v_numero_projetos NUMBER;

 BEGIN
    SELECT COUNT(*) INTO v_existe FROM Departamento WHERE cod_dep = p_cod_dep;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Departamento informado não existe!');
    END IF;

    SELECT COUNT(DISTINCT fp.cod_proj_r) INTO v_numero_projetos FROM Funcionarios f 
    JOIN FuncionariosProjetos fp ON fp.cod_func_r = f.cod_func WHERE f.cod_dep_r = p_cod_dep;

    RETURN v_numero_projetos;
 END;
/
