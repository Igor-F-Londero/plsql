--Procedure com tratamento completo de exceções 

DECLARE 
    --exceção customizada
    e_livro_indisponivel EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_livro_indisponivel, -20001);

    v_id_livro NUMBER := 3;
    v_disponivel livros.disponivel%TYPE;

BEGIN
    --Busca o livro (pode lançar NO_DATA_FOUND)
    SELECT titulo, disponivel INTO v_titulo, v_disponivel
    FROM livros WHERE id_livro = v_id_livro;
    
    --Valida disponibilidade de livros e lança exceção customizada

    IF v_disponivel = 'N' THEN
    RAISE_APPLICATION_ERROR(-20001,
    'Livro  ' || v_titulo || 'não está disponivel');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Emprestimo liberado: ' || v_titulo);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: Livro #' || v_id_livro || ' não existe.');

    WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: Múltiplos registros encontrados. ');

    WHEN e_livro_indisponivel THEN
    DBMS_OUTPUT.PUT_LINE('AVISO !  '|| SQLERRM); --SQLERRM??

    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('ERRO inesperado: ' || SQLERRM);
    DBMS_OUTPUT.PUT_LINE('Código: ' || SQLERRM);

    RAISE; -- relança para o chamador?

END;
/

  
