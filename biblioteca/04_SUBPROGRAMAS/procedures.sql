CREATE OR REPLACE PROCEDURE registrar_emprestimo(
    p_id_livro IN livro.id_livro%TYPE,
    p_id_membro IN membros.p_id_membro,
    p_dias IN NUMBER DEFAULT 14,
    p_id_emp OUT emprestimos.p_id_emp%TYPE
) AS
    v_disponivel livros.disponivel%TYPE;
BEGIN
    --Verifica a disponibilidade

    SELECT disponivel INTO v_disponivel
    FROM livros WHERE id_livro = p_id_livro
    FOR UPDATE; -- explicação -> for update?

    IF v_disponivel = 'N' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Livro Indisponível.');
    END IF;


    --Gera id com sequence (criar CREATE SEQUENCE seq_emprestimo START WITH 1)
    SELECT NVL(MAX(id_emprestimo),0)+1
        INTO p_id_emp FROM emprestimos;

    INSERT INTO emprestimos VALUES (
        p_id_emp, p_id_livro, p_id_membro,
        SYSDATE, SYSDATE + p_dias, NULL
    );

    UPDATE livros SET disponivel = 'N'
        WHERE id_livro = p_id_livro;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Empréstimo #' || p_id_emp || ' registrado');

EXCEPTION
    WHEN OTHERS THEN --explicação
        ROLLBACK; 
        RAISE;
END registrar_emprestimo;-- até aqui
/