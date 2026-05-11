DECLARE 
    CURSOR c_livro_disponiveis IS
        SELECT id_livro, titulo, autor
            FROM livros
        WHERE disponivel ='S'
        ORDER BY titulo;

    v_livro c_livro_disponiveis%ROWTYPE --herda toda a linha
    v_cont NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Livros Disponíveis ===');
    
    OPEN c_livro_disponiveis;
    LOOP 
        FETCH c_livro_disponiveis INTO v_livro;
        EXIT WHEN c_livro_disponiveis%NOTFOUD;

    v_cont := v