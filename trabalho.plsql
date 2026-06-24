SET SERVEROUTPUT ON;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Resultado CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Posicao CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Campeonato CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Corrida CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Piloto CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Equipe CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Pais CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
-- Questão 1
CREATE TABLE Pais (
    sigla VARCHAR2(3) PRIMARY KEY,
    nome  VARCHAR2(50) NOT NULL
);

CREATE TABLE Equipe (
    codigo NUMBER PRIMARY KEY,
    nome   VARCHAR2(100) NOT NULL
);

CREATE TABLE Piloto (
    codigo    NUMBER PRIMARY KEY,
    nome      VARCHAR2(100) NOT NULL,
    dataNasc  DATE NOT NULL,
    codEquipe NUMBER NOT NULL,
    sigla     VARCHAR2(3) NOT NULL,
    CONSTRAINT fk_piloto_equipe
        FOREIGN KEY (codEquipe)
        REFERENCES Equipe (codigo),
    CONSTRAINT fk_piloto_pais
        FOREIGN KEY (sigla)
        REFERENCES Pais (sigla)
);

CREATE TABLE Corrida (
    data    DATE PRIMARY KEY,
    duracao VARCHAR2(20) NOT NULL
);

CREATE TABLE Campeonato (
    codigo    NUMBER PRIMARY KEY,
    ano       NUMBER(4) NOT NULL,
    descricao VARCHAR2(100) NOT NULL
);

CREATE TABLE Posicao (
    codPiloto     NUMBER,
    codCampeonato NUMBER,
    pontos        NUMBER DEFAULT 0 NOT NULL,
    CONSTRAINT pk_posicao
        PRIMARY KEY (codPiloto, codCampeonato), 
        FOREIGN KEY (codPiloto)
        REFERENCES Piloto (codigo),
    CONSTRAINT fk_posicao_campeonato
        FOREIGN KEY (codCampeonato)
        REFERENCES Campeonato (codigo)
);

CREATE TABLE Resultado (
    codPiloto NUMBER,
    data      DATE,
    posGrid   NUMBER NOT NULL,
    posFinal  NUMBER NOT NULL,
    CONSTRAINT pk_resultado
        PRIMARY KEY (codPiloto, data),
    CONSTRAINT fk_resultado_piloto
        FOREIGN KEY (codPiloto)
        REFERENCES Piloto (codigo),
    CONSTRAINT fk_resultado_corrida
        FOREIGN KEY (data)
        REFERENCES Corrida (data)
);

INSERT INTO Pais (sigla, nome) VALUES ('BRA', 'Brasil');
INSERT INTO Pais (sigla, nome) VALUES ('GBR', 'Reino Unido');
INSERT INTO Pais (sigla, nome) VALUES ('NED', 'Paises Baixos');
INSERT INTO Pais (sigla, nome) VALUES ('MON', 'Monaco');
INSERT INTO Pais (sigla, nome) VALUES ('ESP', 'Espanha');
INSERT INTO Pais (sigla, nome) VALUES ('AUS', 'Australia');

INSERT INTO Equipe (codigo, nome) VALUES (1, 'Ferrari');
INSERT INTO Equipe (codigo, nome) VALUES (2, 'Mercedes');
INSERT INTO Equipe (codigo, nome) VALUES (3, 'McLaren');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (1, 'Carlos Silva', TO_DATE('10/05/1995', 'DD/MM/YYYY'), 1, 'BRA');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (2, 'James Wilson', TO_DATE('18/08/1994', 'DD/MM/YYYY'), 1, 'GBR');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (3, 'Max de Vries', TO_DATE('30/09/1997', 'DD/MM/YYYY'), 2, 'NED');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (4, 'Louis Martin', TO_DATE('16/10/1996', 'DD/MM/YYYY'), 2, 'MON');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (5, 'Diego Garcia', TO_DATE('12/02/1998', 'DD/MM/YYYY'), 3, 'ESP');

INSERT INTO Piloto (codigo, nome, dataNasc, codEquipe, sigla)
VALUES (6, 'Jack Brown', TO_DATE('04/04/1999', 'DD/MM/YYYY'), 3, 'AUS');

INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('15/03/2026', 'DD/MM/YYYY'), '01:32:18');

INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('29/03/2026', 'DD/MM/YYYY'), '01:28:45');

INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('12/04/2026', 'DD/MM/YYYY'), '01:35:10');

INSERT INTO Campeonato (codigo, ano, descricao)
VALUES (1, 2026, 'Campeonato Mundial de Corridas 2026');

INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (1, 1, 0);
INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (2, 1, 0);
INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (3, 1, 0);
INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (4, 1, 0);
INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (5, 1, 0);
INSERT INTO Posicao (codPiloto, codCampeonato, pontos) VALUES (6, 1, 0);

COMMIT;
--

--Questão 2
CREATE OR REPLACE FUNCTION calcular_pontos (
    p_posFinal IN NUMBER
) RETURN NUMBER
IS
BEGIN
    IF p_posFinal IS NULL OR p_posFinal < 1 THEN
        RETURN 0;
    END IF;

    CASE p_posFinal
        WHEN 1 THEN RETURN 25;
        WHEN 2 THEN RETURN 18;
        WHEN 3 THEN RETURN 15;
        WHEN 4 THEN RETURN 12;
        WHEN 5 THEN RETURN 10;
        WHEN 6 THEN RETURN 8;
        ELSE RETURN 0;
    END CASE;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao calcular pontos da corrida: ' || SQLERRM);
        RETURN 0;
END calcular_pontos;
/


--Procedure Questão 2
CREATE OR REPLACE PROCEDURE registra_resultado (
    p_codPiloto IN NUMBER,
    p_data      IN DATE,
    p_posGrid   IN NUMBER,
    p_posFinal  IN NUMBER
)
IS
    v_pontos NUMBER;
    v_nome   Piloto.nome%TYPE;
BEGIN
    v_pontos := calcular_pontos(p_posFinal);

    SELECT nome
      INTO v_nome
      FROM Piloto
     WHERE codigo = p_codPiloto;

    INSERT INTO Resultado (codPiloto, data, posGrid, posFinal)
    VALUES (p_codPiloto, p_data, p_posGrid, p_posFinal);

    DBMS_OUTPUT.PUT_LINE(
        'Resultado registrado. Piloto: ' || v_nome ||
        ' | Posição final: ' || p_posFinal ||
        ' | Pontos calculados: ' || v_pontos
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erro: piloto não encontrado.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erro: já existe resultado para este piloto nesta corrida.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro: valor inválido informado na procedure.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao registrar resultado: ' || SQLERRM);
END registra_resultado;
/

-- Trigger da Questão 3:


CREATE OR REPLACE TRIGGER atualiza_pontos
AFTER INSERT ON Resultado
FOR EACH ROW
DECLARE
    v_pontos        NUMBER;
BEGIN
    v_pontos := calcular_pontos(:NEW.posFinal);

    UPDATE Posicao
        SET pontos = pontos + v_pontos
        WHERE codPiloto = :NEW.codPiloto
        AND codCampeonato = 1;

    IF SQL%ROWCOUNT = 0 THEN
        raise_application_error(
            -20002,
            'Piloto não cadastrado na tabela Posicao para o campeonato 1.'
        );
    END IF;
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro: valor inválido ao atualizar pontos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao atualizar pontos: ' || SQLERRM);
        RAISE;
END atualiza_pontos;
/

BEGIN
    registra_resultado(1, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 1, 1);
    registra_resultado(2, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 2, 2);
    registra_resultado(3, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 3, 3);
    registra_resultado(4, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 4, 4);
    registra_resultado(5, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 5, 5);
    registra_resultado(6, TO_DATE('15/03/2026', 'DD/MM/YYYY'), 6, 6);
END;
/

BEGIN
    registra_resultado(2, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 1, 1);
    registra_resultado(1, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 2, 2);
    registra_resultado(4, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 3, 3);
    registra_resultado(3, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 4, 4);
    registra_resultado(6, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 5, 5);
    registra_resultado(5, TO_DATE('29/03/2026', 'DD/MM/YYYY'), 6, 6);
END;
/

BEGIN
    registra_resultado(3, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 1, 1);
    registra_resultado(4, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 2, 2);
    registra_resultado(1, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 3, 3);
    registra_resultado(2, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 4, 4);
    registra_resultado(5, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 5, 5);
    registra_resultado(6, TO_DATE('12/04/2026', 'DD/MM/YYYY'), 6, 6);
END;
/

COMMIT;

SELECT p.nome, pos.codCampeonato, pos.pontos
FROM Posicao pos
JOIN Piloto p ON p.codigo = pos.codPiloto
ORDER BY pos.pontos DESC, p.nome;

--
CREATE OR REPLACE FUNCTION calcular_idade(p_codPiloto IN NUMBER) RETURN NUMBER IS
    v_dataNasc Piloto.dataNasc%TYPE;
    v_idade    NUMBER;
BEGIN
    select dataNasc into v_dataNasc from Piloto where codigo = p_codPiloto;
    v_idade :=  floor(months_between(sysdate, v_dataNasc)/12);
    RETURN v_idade;
END calcular_idade;
/


