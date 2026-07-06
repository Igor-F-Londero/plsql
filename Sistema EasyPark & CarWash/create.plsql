SET SERVEROUTPUT ON;

create or replace function fn_faturamentoVeiculo(
    p_placa in registro_estacionamento.placaVeiculo%type
)return number
is
v_valor_est number :=0;
v_servicos_assoc number :=0;

begin 

    select NVL(sum(r.valorTotal),0) into v_valor_est
    from registro_estacionamento r
    where p_placa = r.placaVeiculo;

    select NVL(sum(s.valorServico),0) into v_servicos_assoc
    from registro_estacionamento r
    inner join servico_lavagem s
    on r.idRegistro = s.idRegistro
    where p_placa = r.placaVeiculo;

    if v_valor_est is not null or v_servicos_assoc is not null then
        return v_valor_est + v_servicos_assoc;
    else
        raise_application_error(-20001, 'ERROR');
    end if;
end;
/

create or replace function fn_TemVagaLivre(
    p_tipoVaga in vaga.tipoVaga%type
)return varchar2
is
v_status_vaga number :=0;
begin

    select count(*) into v_status_vaga from vaga
    where p_tipoVaga = tipoVaga 
    and status = 'LIVRE';
    
    
    if v_status_vaga > 0 then
        return 'SIM';
    else
        return 'NÃO';
    end if;

    commit;
end;
/

create or replace function fn_VerificaRetencao(
    p_idRegistro in registro_estacionamento.idRegistro%type,
    p_diasLimite in NUMBER
)return varchar2
is
v_data_entrada date;
v_diferenca number :=0 ;

begin

    select  dataEntrada into v_data_entrada from registro_estacionamento
    where p_idRegistro = idRegistro;

    v_diferenca :=trunc(sysdate - v_data_entrada);--Se a data entrada for há 2 dias e meio (2,5), o resultado final da conta será 2 (arredondado para baixo).
    for i in 1..v_diferenca loop

        if i > p_diasLimite then
            return'CRITICO';
        end if;

    end loop;
    return 'REGULAR';


end;
/
