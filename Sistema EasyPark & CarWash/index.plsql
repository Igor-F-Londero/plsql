-- Caso necessário limpar o ambiente anterior:
-- DROP TABLE servico_lavagem CASCADE CONSTRAINTS;
-- DROP TABLE registro_estacionamento CASCADE CONSTRAINTS;
-- DROP TABLE vaga CASCADE CONSTRAINTS;
-- DROP TABLE veiculo CASCADE CONSTRAINTS;

CREATE TABLE veiculo (
    placa VARCHAR2(10) PRIMARY KEY,
    modelo VARCHAR2(50) NOT NULL,
    tipo VARCHAR2(20) NOT NULL -- 'SEDAN', 'SUV', 'MOTO'
);

CREATE TABLE vaga (
    idVaga NUMBER PRIMARY KEY,
    numero VARCHAR2(10) NOT NULL,
    status VARCHAR2(20) DEFAULT 'LIVRE', -- 'LIVRE', 'OCUPADA'
    tipoVaga VARCHAR2(20) NOT NULL -- 'COMUM', 'VIP', 'MOTO'
);

CREATE TABLE registro_estacionamento (
    idRegistro NUMBER PRIMARY KEY,
    placaVeiculo VARCHAR2(10) NOT NULL,
    idVaga NUMBER NOT NULL,
    dataEntrada DATE NOT NULL,
    dataSaida DATE DEFAULT NULL,
    valorTotal NUMBER(6,2) DEFAULT 0.00,
    FOREIGN KEY (placaVeiculo) REFERENCES veiculo(placa),
    FOREIGN KEY (idVaga) REFERENCES vaga(idVaga)
);

CREATE TABLE servico_lavagem (
    idServico NUMBER PRIMARY KEY,
    idRegistro NUMBER NOT NULL,
    tipoLavagem VARCHAR2(30) NOT NULL, -- 'SIMPLES', 'COMPLETA', 'CERA'
    valorServico NUMBER(6,2) NOT NULL,
    statusServico VARCHAR2(20) DEFAULT 'PENDENTE', -- 'PENDENTE', 'CONCLUIDO'
    FOREIGN KEY (idRegistro) REFERENCES registro_estacionamento(idRegistro)
);

-- Carga de Veículos
INSERT INTO veiculo VALUES ('ABC1234', 'Toyota Corolla', 'SEDAN');
INSERT INTO veiculo VALUES ('XYZ5678', 'Jeep Compass', 'SUV');
INSERT INTO veiculo VALUES ('MOTO123', 'Honda Biz', 'MOTO');
INSERT INTO veiculo VALUES ('BBB9999', 'Chevrolet Onix', 'SEDAN');

-- Carga de Vagas
INSERT INTO vaga VALUES (1, 'A-01', 'OCUPADA', 'COMUM');
INSERT INTO vaga VALUES (2, 'A-02', 'LIVRE', 'COMUM');
INSERT INTO vaga VALUES (3, 'V-01', 'OCUPADA', 'VIP');
INSERT INTO vaga VALUES (4, 'M-01', 'LIVRE', 'MOTO');

-- Carga de Registros (Datas usando TO_DATE para evitar conflitos de formato)
INSERT INTO registro_estacionamento VALUES (101, 'ABC1234', 1, TO_DATE('06/07/2026 08:00:00', 'DD/MM/YYYY HH24:MI:SS'), TO_DATE('06/07/2026 10:00:00', 'DD/MM/YYYY HH24:MI:SS'), 20.00);
INSERT INTO registro_estacionamento VALUES (102, 'XYZ5678', 3, TO_DATE('06/07/2026 09:15:00', 'DD/MM/YYYY HH24:MI:SS'), NULL, 0.00);
INSERT INTO registro_estacionamento VALUES (103, 'MOTO123', 4, TO_DATE('05/07/2026 14:00:00', 'DD/MM/YYYY HH24:MI:SS'), TO_DATE('05/07/2026 15:00:00', 'DD/MM/YYYY HH24:MI:SS'), 10.00);

-- Carga de Serviços de Lavagem
INSERT INTO servico_lavagem VALUES (1, 101, 'SIMPLES', 40.00, 'CONCLUIDO');
INSERT INTO servico_lavagem VALUES (2, 102, 'COMPLETA', 70.00, 'PENDENTE');