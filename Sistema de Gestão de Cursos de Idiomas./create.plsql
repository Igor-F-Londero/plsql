SET SERVEROUTPUT ON;



SELECT a.nome , c.descricao ,t.IDTURMA FROM ALUNO A LEFT JOIN MATRICULA m  ON a.CODIGO = m.CODIGO LEFT JOIN TURMA t ON m.id = t.IDTURMA LEFT JOIN CURSO c ON t.IDCURSO = c.IDCURSO;

select m.codigoMatricula, COUNT(p.NUMEROPARCELA) FROM parcelasCurso p inner join MATRICULA m ON p.codigoMat = m.codigoMatricula group by m.CODIGOMATRICULA order by COUNT(p.NUMEROPARCELA) desc;



create or replace function fn_CalcularSaldoDevedor(
    p_codM in matricula.codigoMatricula%TYPE
)RETURN NUMBER
is 
v_total_aluno NUMBER;

begin

    select SUM(valor) into v_total_aluno from  parcelasCurso p inner join MATRICULA m on p.codigoMat = m.codigoMatricula where p.dataPagto is null AND m.codigoMatricula = p_codM;

    RETURN v_total_aluno;
exception
    when NO_DATA_FOUND then 
        DBMS_OUTPUT.PUT_LINE('Erro: nenhum dado encontrado');
    when OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro:' || SQLERRM);
end;
/

commit;

create or replace function fn_VerificarCapacidade(
    p_idTur in turma.IDTURMA%TYPE
)RETURN BOOLEAN
is
v_vagas_dispo number;

begin 
    
    select nrVagas into v_vagas_dispo from turma where p_idTur = turma.idTurma;

    if v_vagas_dispo > 0 then
        return True;
    ELSE 
        return false;
end if;
    
end;
/


create or replace function fn_projetarJurosCompostos(
    v_valor in NUMBER,
    v_taxa in  NUMBER,
    v_mesesAtrasados in INTEGER

)RETURN NUMBER 
is

v_valorFinal number;
begin 
    
    if v_mesesAtrasados <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: o aluno deve ter parcelas atrasadas para realizar este calculo!');
        return v_valor;
    ELSE
        v_valorFinal := v_valor;
        
        for i in 1..v_mesesAtrasados LOOP

            v_valorFinal := v_valorFinal +(v_valorFinal * (v_taxa / 100));
        end loop;
        return v_valorFinal;
    end if;
end;
/
commit;


create or replace function fn_verificaRiscoDesistencia(
    v_codM in matricula.codigoMatricula%TYPE

)RETURN VARCHAR2
is
v_ParcAtrasada Number := 0;

CURSOR c_historico_parcela IS
    select dataVenc, dataPagto, valor 
    FROM parcelasCurso
    WHERE codigoMat = v_codM
    ORDER BY dataVenc ASC;
begin 

    for ponteiro in c_historico_parcela LOOP
        
        --SYSDATE retorna a data e a hora atuais definidas para o sistema operacional 
        if ponteiro.dataVenc < SYSDATE AND ponteiro.dataPagto IS NULL THEN
            v_ParcAtrasada := v_ParcAtrasada + 1;

            if v_ParcAtrasada = 3 THEN
                RETURN 'RISCO ALTO';
            END IF;

        ELSE    
            v_ParcAtrasada := 0;
        end IF;

    END LOOP;
    
    RETURN 'RISCO REGULAR';
END;
/


