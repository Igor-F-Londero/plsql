
CREATE TABLE livros (
    id_livro NUMBER PRIMARY KEY,
    titulo VARCHAR2(200) NOT NULL,
    autor VARCHAR2(100),
    ano NUMBER(4),
    disponivel CHAR(1) DEFAULT 'S' -- S=sim N=não

);

CREATE TABLE membros(
    id_membro NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    email VARCHAR(150),
    data_cadastro DATE DEFAULT SYSDATE
);

CREATE TABLE emprestimos (
    id_emprestimo NUMBER PRIMARY KEY,
    id_livro NUMBER REFERENCES livros(id_livro),
    id_membro NUMBER REFERENCES membros(id_membro),
    data_saida DATE DEFAULT SYSDATE,
    data_prevista DATE,
    data_retorno DATE

);


--PLSQL

DECLARE
    v_msg VARCHAR2(100);

BEGIN
    v_msg :='Biblioteca criada com sucesso! ';
    DBMS_OUTPUT.PUT_LINE(v_msg);
    DBMS_OUTPUT.PUT_LINE('Data atual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY'));

END;
/ 

