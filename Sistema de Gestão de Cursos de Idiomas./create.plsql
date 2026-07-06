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


/*create or replace procedure pr_pagaParcela(
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

*/

create or replace procedure pr_paga_parcela(
    p_numParc in parcelacurso.numeroParcela%type,
    p_codM in matricula.codigoMatricula%type
)is
v_data_pgto date;
begin

    select dataPagto into v_data_pgto from parcelacurso
    where numeroParcela = p_numParc and 
    codigoMat = p_codM;

    if v_data_pgto is null then
        update parcelacurso set dataPagto = SYSDATE 
        where numeroParcela = p_numParc 
        and codigoMat = p_codM;

        DBMS_OUTPUT.PUT_LINE('Parcela paga com sucesso!');
    ELSE
        raise_application_error(-20001,'Parcela já foi paga!');
    end if;
end;
/


--Questão 4.1: Cancelamento de Matrícula (Operação DELETE)
--Enunciado: Crie uma procedure chamada pr_CancelarMatricula que receba apenas o código da matrícula (p_codMatricula).
create or replace procedure pr_CancelarMatricula(
    p_codM in matricula.codigoMatricula%type
)is
begin 
    
    delete from parcelascurso where codigoMat = p_codM;

    delete from matricula where codigoMatricula = p_codM;
    commit;

    DBMS_OUTPUT.PUT_LINE('Aluno excluido!');

end;
/


/* 
Questão 4.2: Atualização de Vagas Manual (Operação com Condicional)

    Contexto de Projeto: A coordenação pedagógica quer uma rotina para alterar manualmente o limite de vagas de uma turma, mas com uma trava de segurança: nenhuma turma de idioma pode ter menos de 5 vagas e nem mais de 15 vagas por questões de qualidade de ensino.

    Enunciado: Crie uma procedure chamada pr_AlterarLimiteVagas que receba o ID da turma (p_idTurma) e a nova quantidade de vagas desejada (p_novasVagas).
 */
create or replace procedure pr_AlterarLimiteVagas(
    p_idTurma in turma.idTurma%type,
    p_novasVagas in number
)is 
begin 
    if p_novasVagas > 15 or p_novasVagas < 5 then
        raise_application_error(-20001, 'Erro: quantidade de vagas invalida, não deve ter menos de 5 ou mais de 15 vagas disponiveis!.');
    else
        update turma set nrVagas = p_novasVagas where idTurma = p_idTurma;
    end if;

exception
    when OTHERS then
        raise_application_error(-20003, 'ERROR ' || SQLERRM);
end;
/


/*
A Anatomia de uma Trigger (As 4 Perguntas)

Sempre que ler um enunciado de Trigger, monte o topo dela respondendo a isto:

    QUANDO o alarme deve disparar?

        Antes da ação acontecer (BEFORE) ou depois que ela já salvou no banco (AFTER)?

        Para a Questão 7: Como queremos impedir que uma parcela paga seja excluída, o alarme tem que tocar antes (BEFORE) da exclusão acontecer.

    QUAL É A AÇÃO que dispara o sensor?

        É uma inserção (INSERT), alteração (UPDATE) ou exclusão (DELETE)?

        Para a Questão 7: O enunciado fala em "impedir a exclusão", logo, o evento é DELETE.

    ONDE o sensor está instalado?

        Qual é a tabela que está sendo vigiada?

        Para a Questão 7: O sensor fica na tabela parcelasCurso.

    COMO o alarme deve analisar os dados?

        Ele deve olhar o comando como um todo ou deve olhar cada linha que está sendo afetada, uma por uma?

        Para a Questão 7: Como o usuário pode tentar apagar 5 parcelas de uma vez e precisamos validar o estado de cada boleto individualmente, usamos a cláusula padrão FOR EACH ROW (Para Cada Linha).    


    :NEW: Guarda os dados novos que estão tentando entrar no banco (só existe no INSERT e UPDATE).
    :OLD: Guarda os dados antigos que já estavam salvos na tabela antes da pessoa mexer (existe no UPDATE e DELETE).

*/
create or replace trigger impedeExclusao --NOME do trigger
before --QUANDO o alarme deve disparar? Antes da ação acontecer (BEFORE) ou depois que ela já salvou no banco (AFTER)?
delete --QUAL É A AÇÃO que dispara o sensor? É uma inserção (INSERT), alteração (UPDATE) ou exclusão (DELETE)?   
on parcelasCurso --ONDE o sensor está instalado? Qual é a tabela que está sendo vigiada?
for each row -- COMO o alarme deve analisar os dados? Ele deve olhar o comando como um todo ou deve olhar cada linha que está sendo afetada, uma por uma?
begin
    
    if :OLD.dataPagto is not null then
        raise_application_error(-20001, 'ERROR: Parcela ja foi paga, não pode ser excluida!!');
    end if;
end;
/


create or replace trigger cpfAluno
before
insert
on Aluno
for each row
begin

    if length(:NEW.cpf) != 11 then
        raise_application_error(-20001, 'ERROR: O cpf não deve possuir mais de 11 caracteres');
    end if;
end;
/