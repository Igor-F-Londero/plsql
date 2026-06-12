
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
