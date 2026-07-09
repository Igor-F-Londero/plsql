CREATE TABLE medicos (
    id_medico NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    especialidade VARCHAR2(50),
    status_crm VARCHAR2(20) -- 'ATIVO', 'SUSPENSO'
);

CREATE TABLE pacientes (
    id_paciente NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    plano_saude VARCHAR2(20), -- 'PARTICULAR', 'CONVENIO'
    status_financeiro VARCHAR2(20) -- 'REGULAR', 'PENDENTE'
);

CREATE TABLE agendamentos (
    id_agenda NUMBER PRIMARY KEY,
    id_medico NUMBER,
    id_paciente NUMBER,
    data_hora DATE,
    status_consulta VARCHAR2(20), -- 'AGENDADA', 'REALIZADA', 'CANCELADA'
    CONSTRAINT fk_med FOREIGN KEY (id_medico) REFERENCES medicos(id_medico),
    CONSTRAINT fk_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
);

CREATE TABLE leitos (
    id_leito NUMBER PRIMARY KEY,
    tipo_leito VARCHAR2(30), -- 'UTI', 'ENFERMARIA'
    status_ocupacao VARCHAR2(20) DEFAULT 'LIVRE' -- 'LIVRE', 'OCUPADO'
);

INSERT INTO medicos VALUES (10, 'Dr. Arnaldo Silva', 'CARDIOLOGIA', 'ATIVO');
INSERT INTO medicos VALUES (20, 'Dra. Roberta Souz', 'PEDIATRIA', 'SUSPENSO');

INSERT INTO pacientes VALUES (1, 'Marcos Moura', 'CONVENIO', 'REGULAR');
INSERT INTO pacientes VALUES (2, 'Julia Mendes', 'PARTICULAR', 'PENDENTE');

INSERT INTO agendamentos VALUES (501, 10, 1, TO_DATE('09/07/2026 14:00', 'DD/MM/YYYY HH24:MI'), 'AGENDADA');
INSERT INTO leitos VALUES (101, 'UTI', 'LIVRE');
COMMIT;