--Calcula multa por atraso
CREATE OR REPLACE FUNCTION calcular_multa(
    p_id_emprestimo IN NUMBER
) RETURN NUMBER AS
    v_prevista DATE;
    v_retorno DATE;
    v_dias_atraso NUMBER;

BEGIN
    -- NVL(data_retorno, SYSDATE) verifica se a data_retorno é NULL
    -- Se for NULL (livro ainda não devolvido), usa a data de hoje (SYSDATE)
    -- Se não for NULL, usa o valor real da coluna
    -- Isso permite calcular multa baseado em atraso até hoje se o livro não foi devolvido
    SELECT data_prevista, NVL(data_retorno, SYSDATE)
    INTO v_prevista, v_retorno
    FROM emprestimos WHERE id_emprestimo = p_id_emprestimo;

    v_dias_atraso := GREATEST(v_retorno - v_prevista, 0);   
    RETURN ROUND(v_dias_atraso *2.50, 2); --R$ 2,50/dias
END calcular_multa;
/

DECLARE
v_id NUMBER;

BEGIN
    registrar_emprestimo(2,1,7, v_id);
    DBMS_OUTPUT.PUT_LINE('Multa atual: R$ ' || calcular_multa(v_id));
END;
/



