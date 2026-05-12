-- Inserindo dados de teste

INSERT INTO livros VALUES (1,'Clean Code','Robert Martin',2008,'S');
INSERT INTO livros VALUES (2,'O Hobbit','Tolkien',1937,'S');
INSERT INTO livros VALUES (3,'1984','George Orwell',1949,'N');

INSERT INTO membros VALUES (1,'Igor','igor@email.com',SYSDATE);
INSERT INTO membros VALUES (2,'Ana','ana@email.com',SYSDATE);

COMMIT;

DECLARE    --O %TYPE é muito útil: se a coluna mudar de tamanho no futuro, 
            --sua variável acompanha automaticamente. Sempre prefira %TYPE a VARCHAR2(100) fixo.
            
v_id_livro  livros.id_livro%TYPE := 3; --herda o tipo da coluna
v_titulo    livros.titulo%TYPE;
v_disponivel    livros.disponivel%TYPE;
v_status    VARCHAR2(50);

BEGIN
    SELECT titulo,disponivel
    INTO v_titulo, v_disponivel
    FROM livros WHERE id_livro = v_id_livro;

    --IF/ELSIF/ELSE

    IF v_disponivel = 'S' THEN
        v_status := 'Disponivel para empréstimo';
    ELSIF v_disponivel = 'N' THEN
        v_status :='Emprestado no momento';
    ELSE
    v_status := 'Desconhecido';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Livro: '|| v_titulo);
    DBMS_OUTPUT.PUT_LINE('Status '|| v_status);

    DBMS_OUTPUT.PUT_LINE(
        CASE v_disponivel
        WHEN 'S' THEN '✓ Livre'
        WHEN 'N' THEN '✗ Ocupado'
        ELSE '? Indefinido'
    END

    );
    END;

    