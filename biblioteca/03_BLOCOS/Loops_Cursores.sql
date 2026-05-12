DECLARE 
    CURSOR c_livro_disponiveis IS
        SELECT id_livro, titulo, autor
            FROM livros
        WHERE disponivel ='S'
        ORDER BY titulo;

    v_livro c_livro_disponiveis%ROWTYPE ;--herda toda a linha
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Livros Disponíveis ===');
    
    OPEN c_livro_disponiveis;
LOOP 
    FETCH c_livro_disponiveis INTO v_livro;
    EXIT WHEN c_livro_disponiveis%NOTFOUND;

    v_count := v_count +1;
    DBMS_OUTPUT.PUT_LINE(
    v_count || '- '  || v_livro.titulo ||
    '-' || v_livro.autor
    );

END LOOP;
    CLOSE c_livro_disponiveis;
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_count || ' livro(s) ');

END;
/

-- cursor FOR (mais simples - abre, faz fetch e fecha )

BEGIN
    FOR rec IN (SELECT titulo, ano FROM livros ORDER BY ano) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.titulo || '( ' || rec.ano || ' )');
    END LOOP;
END;
/
