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
--A declaração do cursor é simplesmente um comando SELECT comum, mas que ganha um nome de batismo para que o PL/SQL possa chamá-lo mais tarde.
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

create or replace function fn_verificaInatividadeTurma(
    p_idTur in turma.idTurma%TYPE,
    v_parcelasAtrasadas in NUMBER
)return VARCHAR2
is
v_duracao_total NUMBER;
v_duracao_texto VARCHAR2(50);
begin

    select duracao  into v_duracao_texto from turma t
    inner join curso c on t.idCurso = c.idCurso where p_idTur = t.idTurma;

    v_duracao_total := TO_NUMBER(v_duracao_texto );
    
    for i in 1..v_duracao_total loop
        if v_parcelasAtrasadas > v_duracao_total / 2 THEN
            RETURN 'EVASÃO CRÍTICA !';
        END IF;
    END LOOP;
    RETURN 'CONTROLADO !';

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO!! ' || SQLERRM);
END;
/

create or replace function fn_mediaPonderadaMatricula(
    p_codM in matricula.codigoMatricula%TYPE

)RETURN NUMBER
is 
v_total_parcelas NUMBER :=0 ;
v_soma_valores NUMBER := 0;

CURSOR c_valor_parcelas IS
    select valor
    from parcelasCurso p 
    where p_codM = p.codigoMat;

BEGIN

    for ponteiro in c_valor_parcelas LOOP
        v_total_parcelas := v_total_parcelas + 1; 
        if ponteiro.valor <= 100 THEN
            v_soma_valores := v_soma_valores + ponteiro.valor;
        ELSE
            v_soma_valores :=  v_soma_valores + (ponteiro.valor * 1.2);
        end IF;
    end LOOP;

    RETURN v_soma_valores / v_total_parcelas;
        
end;
/

create or replace procedure pr_AplicarDescontoParcela(
    p_codM in matricula.codigoMatricula%TYPE,
    p_numParc in parcelasCurso.NUMEROPARCELA%TYPE,
    p_porcenParcela NUMBER := 0
)IS
begin 

    UPDATE parcelasCurso  SET valor = valor - (valor * (p_porcenParcela / 100))
    where p_codM = codigoMat
    AND p_numParc = numeroParcela;
    
    commit;
end;
/


create or replace procedure pr_TransferirAluno(
    p_codM in matricula.codigoMatricula%TYPE,
    p_idTur in turma.idTurma%TYPE

)IS
BEGIN
    update matricula set id = p_idTur where codigoMatricula = p_codM;

    commit;

END;
/


create or replace procedure pr_pagaParcela(
    p_codM in matricula.codigoMatricula%TYPE,
    p_numParc in parcelasCurso.numeroParcela%TYPE
)is
v_data_pgto date;
begin 

    select dataPagto into v_data_pgto from parcelasCurso
    where numeroParcela = p_numParc and codigoMat = codigoMatricula;

    if v_data_pgto is not null THEN
        DBMS_OUTPUT.PUT_LINE('PARCELA JA PAGA');
    ELSE
        update parcelasCurso SET dataPagto = SYSDATE(dataPagto);
    end if;

    COMMIT;
END;
/