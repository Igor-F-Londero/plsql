-- SPEC: define a interface pública (o que outros podem usar)
CREATE OR REPLACE PACKAGE pkg_biblioteca AS

-- Constante pública
    c_multa_dia CONSTANT NUMBER := 2.50;

-- Procedures públicas
    PROCEDURE registrar_emprestimo(
    p_id_livro  IN NUMBER,
    p_id_membro IN NUMBER,
    p_dias      IN NUMBER DEFAULT 14
    );

    PROCEDURE devolver_livro(
    p_id_emp IN NUMBER
    );
    
-- Função pública
    FUNCTION calcular_multa(
    p_id_emprestimo IN NUMBER
    ) RETURN NUMBER;

-- Relatório de empréstimos em aberto
    PROCEDURE listar_em_aberto;

END pkg_biblioteca;
/

--BODY

CREATE OR REPLACE PACKAGE BODY pkg_biblioteca AS

--variavel privada

g_total_operacoes NUMBER := 0;

-- Esta procedure registra um novo empréstimo de livro para um membro
-- Parâmetros:
--   p_id_livro: ID do livro a emprestar
--   p_id_membro: ID do membro que vai pegar o livro
--   p_dias: Quantos dias o livro pode ficar (padrão: 14 dias)
PROCEDURE registrar_emprestimo(
    p_id_livro IN NUMBER, p_id_membro IN NUMBER, p_dias IN NUMBER DEFAULT 14
) AS
    v_disp livros.disponivel%TYPE;
    v_id NUMBER;

BEGIN
    -- FOR UPDATE bloqueia o livro enquanto verificamos e marcamos como indisponível
    -- Evita race condition: outro usuário não consegue emprestar o mesmo livro ao mesmo tempo
    SELECT disponivel INTO v_disp
        FROM livros WHERE id_livro = p_id_livro FOR UPDATE;
    IF v_disp = 'N' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Livro indisponivel. ');
    END IF;

    -- Gera o próximo ID do empréstimo manualmente
    -- MAX(id_emprestimo) retorna o maior ID existente
    -- NVL(..., 0) se não há registros (resultado NULL), usa 0
    -- +1 incrementa para gerar o próximo ID sequencial
    -- (Obs: idealmente usaria uma SEQUENCE em produção)
    -- SYSDATE na próxima linha é a data/hora atual do sistema
    SELECT NVL (MAX(id_emprestimo),0)+1 INTO v_id FROM emprestimos;
    INSERT INTO emprestimos VALUES(v_id,p_id_livro,p_id_membro,SYSDATE,SYSDATE+p_dias,NULL);
    UPDATE livros SET disponivel='N' WHERE id_livro=p_id_livro;
    g_total_operacoes := g_total_operacoes +1;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Emprestimo # '||v_id|| ' registrado! ');
END;

    PROCEDURE devolver_livro(p_id_emp IN NUMBER) AS
BEGIN

    -- Registra a data de devolução como hoje (SYSDATE = System Date)
    -- Isso marca o empréstimo como finalizado
    UPDATE emprestimos SET data_retorno=SYSDATE WHERE id_emprestimo=p_id_emp;
    UPDATE livros SET disponivel='S'
        WHERE id_livro = (SELECT id_livro FROM emprestimos WHERE id_emprestimo=p_id_emp);
    g_total_operacoes := g_total_operacoes + 1;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Devolução registrada, Multa R$: '|| calcular_multa(p_id_emp));

END;

    FUNCTION calcular_multa(p_id_emprestimo IN NUMBER)
    RETURN NUMBER AS v_prev DATE; v_ret DATE;
BEGIN
    SELECT data_prevista, NVL(data_retorno,SYSDATE)
        INTO v_prev, v_ret FROM emprestimos WHERE id_emprestimo=p_id_emprestimo;
    RETURN ROUND(GREATEST(v_ret-v_prev,0)*c_multa_dia,2);
END;

    -- Esta procedure lista todos os empréstimos ainda não devolvidos
    -- Mostra: quem pegou, qual livro, quando vence, e se está atrasado
    -- Usa JOINs para trazer dados de 3 tabelas: membros, livros, empréstimos
    -- GREATEST(SYSDATE-e.data_prevista,0) calcula dias em atraso (mínimo 0 se não está atrasado)
    PROCEDURE listar_em_aberto AS
BEGIN
    FOR r IN (
        SELECT m.nome, l.titulo, e.data_prevista,
        GREATEST(SYSDATE-e.data_prevista,0) dias_atraso
        FROM emprestimos e JOIN livros l ON l.id_livro=e.id_livro
            JOIN membros m ON m.id_membro=e.id_membro
                WHERE e.data_retorno IS NULL ORDER BY e.data_prevista
        )LOOP
        DBMS_OUTPUT.PUT_LINE(
            r.nome ||' | '|| r.titulo ||
            ' | previsão: '|| TO_CHAR(r.data_prevista, 'DD/MM') ||
            CASE WHEN r.dias_atraso>0 THEN ' *** ATRASO: ' || r.dias_atraso ||'d' ELSE '' END
        );
        END LOOP;
    END;
END pkg_biblioteca;
/

BEGIN
    pkg_biblioteca.registrar_emprestimo(2, 1, 7);
    pkg_biblioteca.listar_em_aberto;
END;
/