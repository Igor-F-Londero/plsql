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


/*

Média Ponderada de Gastos por Tipo de Veículo (Cursor + Loop)
*/


create or replace function fn_MediaPonderadaTipo(
    p_tipoVeiculo in veiculo.tipo%type
)return number
is
v_registros number := 0;
v_soma_valores number := 0;
cursor c_valor_total is
    select valorTotal
    from veiculo v
    inner join registro_estacionamento r 
    on v.placa = r.placaVeiculo
    where v.tipo = p_tipoVeiculo;
begin
    for ponteiro in c_valor_total loop
        v_registros := v_registros + 1;
        if p_tipoVeiculo = 'SUV' then
            v_soma_valores := v_soma_valores +(ponteiro.valorTotal *1.5);
        else
            v_soma_valores := v_soma_valores + ponteiro.valorTotal;
        end if;
    end loop;
    return v_soma_valores / v_registros;
end;
/


--INSERT
create or replace procedure pr_RegistraEntrada(
    p_Placa in veiculo.placa%type,
    p_Registro in registro_estacionamento.idRegistro%type,
    p_Vaga in vaga.idVaga%type
)is
begin

    insert into registro_estacionamento(idRegistro,placaVeiculo,idVaga,dataEntrada,valorTotal)
    values(p_Registro,p_Placa,p_Vaga,sysdate,0);
    commit;
end;
/

--UPDATE
create or replace procedure pr_ConcluirLavagem(
    p_idServico in servico_lavagem.idServico%type
)is
v_status_servico varchar2(20);
begin

    select statusServico into v_status_servico from servico_lavagem s 
    where p_idServico = s.idServico;

    if v_status_servico != 'CONCLUIDO'then
        update servico_lavagem s set statusServico = 'CONCLUIDO'
        where p_idServico = s.idServico;
    else
        raise_application_error(-20001,'ERRO: O serviço ja está com o status concluido... Operação cancelada!');
    end if;
    commit;
exception
    when others then
        raise_application_error(-20002, 'ERRO ' || SQLERRM);
end;
/


create or replace procedure pr_RegistraSaida(
    p_Registro in registro_estacionamento.idRegistro%type,
    p_valorHora in NUMBER
)is
v_data_entrada date;
begin
    select dataEntrada into v_data_entrada from registro_estacionamento r
    where p_Registro = r.idRegistro;


    update registro_estacionamento r set dataSaida = sysdate,
    valorTotal = p_valorHora *(sysdate - v_data_entrada) * 24
    where p_Registro = r.idRegistro;
    commit;

end;
/


create or replace trigger registraEstacionamento
after 
insert
on registro_estacionamento
for each row
begin
    
    update vaga set status = 'OCUPADA'
    where idVaga = :new.idVaga;

end;
/

create or replace trigger vagaErrada
before
insert
on registro_estacionamento 
for each row
declare
    v_tipo_vaga varchar2(20);
    v_tipo_veiculo varchar2(20);
begin

    select tipoVaga into v_tipo_vaga from vaga v
    where v.idVaga = :new.idVaga;
    
    select tipo into v_tipo_vaga from veiculo
    where placa = :new.placaVeiculo;

    if v_tipo_veiculo != v_tipo_vaga then
        raise_application_error(-20001, 'ERRO: Seu veiculo não pode ser alocado nessa vaga!' || SQLERRM);
    end if;
end;
/
