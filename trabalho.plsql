
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

    CONSTRAINT fk_posicao_piloto
        FOREIGN KEY (codPiloto)
        REFERENCES Piloto (codigo),

    CONSTRAINT fk_posicao_campeonato
        FOREIGN KEY (codCampeonato)
        REFERENCES Campeonato (codigo)
);



CREATE TABLE Resultado (
    codPiloto NUMBER,
    data       DATE,
    posGrid    NUMBER NOT NULL,
    posFinal   NUMBER NOT NULL,

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


INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (1, 'Carlos Silva', TO_DATE('10/05/1995', 'DD/MM/YYYY'), 1, 'BRA');

INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (2, 'James Wilson', TO_DATE('18/08/1994', 'DD/MM/YYYY'), 1, 'GBR');

INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (3, 'Max de Vries', TO_DATE('30/09/1997', 'DD/MM/YYYY'), 2, 'NED');

INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (4, 'Louis Martin', TO_DATE('16/10/1996', 'DD/MM/YYYY'), 2, 'MON');

INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (5, 'Diego Garcia', TO_DATE('12/02/1998', 'DD/MM/YYYY'), 3, 'ESP');

INSERT INTO Piloto
    (codigo, nome, dataNasc, codEquipe, sigla)
VALUES
    (6, 'Jack Brown', TO_DATE('04/04/1999', 'DD/MM/YYYY'), 3, 'AUS');



INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('15/03/2026', 'DD/MM/YYYY'), '01:32:18');

INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('29/03/2026', 'DD/MM/YYYY'), '01:28:45');

INSERT INTO Corrida (data, duracao)
VALUES (TO_DATE('12/04/2026', 'DD/MM/YYYY'), '01:35:10');


INSERT INTO Campeonato (codigo, ano, descricao)
VALUES (1, 2026, 'Campeonato Mundial de Corridas 2026');


INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (1, 1, 0);

INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (2, 1, 0);

INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (3, 1, 0);

INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (4, 1, 0);

INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (5, 1, 0);

INSERT INTO Posicao (codPiloto, codCampeonato, pontos)
VALUES (6, 1, 0);

COMMIT;
