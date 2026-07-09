create or replace function fn_ConsultasDia(
    p_idMed in agendamentos.id_medico%type,
    p_data in agendamentos.data_hora%type
)return number
is
v_qtd_agen number :=0;
begin
    select count(id_agenda) into v_qtd_agen
    from agendamentos a
    where p_idMed = a.id_medico
    and trunc(data_hora) =trunc(p_data);-- TRUNC zera as horas para comparar apenas o dia

    return v_qtd_agen;
end;
/

create or replace function fn_VerificaProntuario(
    p_idPaciente in pacientes.id_paciente%type
)return varchar2
is
    v_status varchar2(20);
begin

    select status_financeiro into v_status
    from pacientes
    where p_idPaciente = id_paciente;

    if v_status != 'REGULAR' then
        return 'BLOQUEADO';
    else
        return 'LIBERADO';
    end if;
end;
/

create or replace procedure pr_agendarconsulta(
    p_Medico in agendamentos.id_medico%type,
    p_Paciente in agendamentos.id_paciente%type,
    p_data in agendamentos.data_hora%type
)is

v_status varchar2(20);
begin
    select status_crm into v_status
    from medicos
    where m.id_medico = p_Medico;

    if v_status = 'SUSPENSO' then
        raise_application_error(-20001,'ERRO: Médico suspenso!');
    else
        insert into agendamentos(id_agenda,id_medico,id_paciente,data_hora)
        values(999,p_Medico,p_Paciente,p_data);
    end if;
end;
/

create or replace procedure pr_InternarPaciente(
    p_idLeito in letos.id_leito%type
)is
v_statusLeito varchar2(20);
begin

    select status_ocupacao into v_statusLeito
    from leitos
    where id_leito = p_idLeito;

    if v_statusLeito = 'OCUPADO' then
        raise_application_error(-20001,'LEITO OCUPADO!');
    else
        update leitos set status_ocupacao = 'OCUPADO'
        where id_leito = p_idLeito;
    end if;
end;
/

create or replace trigger tg_BloqPaciente
before
insert
on agendamentos
for each row
declare
v_resultado varchar2(20);
begin

    v_resultado := fn_VerificaProntuario(:new.id_paciente);

    if v_resultado = 'BLOQUEADO' then
        raise_application_error(-20001,'ERRO');
    else
        return;
    end if;
end;
/

create or replace trigger tg_EvitaDuploAgendamento
before
insert
on agendamentos
for each row
declare
v_qtd number :=0;
begin   

    select count(1) into v_qtd
    from agendamentos
    where id_medico = :new.id_medico 
        and data_hora = :new.data_hora;

    if v_qtd > 0 then
        raise_application_error(-20001,'ERRO: O médico ja possui consulta nessa data');
    end if;
end;
/

--

-- bloco 1: functions (retorno de valores)

-- questão 1: função que calcula o total gasto de um cliente somando apenas os pedidos faturados
create or replace function fn_TotalGastocliente(
    p_idCliente in cliente.id_cli%type
)return number
is
v_total_pedido number := 0;
begin
    select nvl(sum(p.total_pedido),0) into v_total_pedido
    from pedido p
    where p.id_cli = p_idCliente 
    and p.status_pedido = 'FATURADO';

    return v_total_pedido;
end;
/

-- questão 2: função que verifica a disponibilidade de estoque para todos os itens de um pedido específico
create or replace function fn_VerificaEstoquePedido(
    p_idPedido in item_pedido.id_ped%type
)return varchar2
is

v_contador number :=0;

cursor c_itemPedido is
    select i.quantidade, p.qtd_estoque
    from item_pedido i 
    inner join produto p 
    on i.id_prod = p.id_prod
    where i.id_ped = p_idPedido;
begin

    for ponteiro in c_itemPedido loop

        if ponteiro.quantidade > ponteiro.qtd_estoque then
            return 'indisponivel';
        end if;

    end loop;
    return 'disponivel';
end;
/


-- bloco 2: procedures (ações e processamento)

-- questão 3: procedimento para inicializar um novo pedido validando se o cliente não está bloqueado
create or replace procedure pr_CriarPedido(
    p_idPedido in pedido.id_ped%type,
    p_idCliente in cliente.id_cli%type
)is
v_statusCliente varchar2;
begin

    select status_cliente  into v_statusCliente 
    from cliente c 
    where c.id_cli = p_idCliente;

    if v_statusCliente = 'BLOQUEADO' then
        raise_application_error(-20001, 'ERRO:  Cliente bloqueado');
    else
        insert into edido(id_ped, id_cli, data_pedido,total_pedido)
        values (p_idPedido,p_idCliente,sysdate,0);
    end if;
commit;
end;
/

-- questão 4: procedimento para inserir item calculando automaticamente o subtotal (preco * quantidade)
create or replace procedure pr_AdicionarItem(
    p_idItem in item_pedido.id_item%type,
    p_idPedido in item_pedido.id_ped%type,
    p_idProduto in item_pedido.id_prod%type,
    p_quantidade in item_pedido.quantidade%type
)is
v_preco number(6,2) :=0.00;
v_resultado number(6,2) :=0.00;
begin
    
    select preco_unitario into v_preco
    from produto p 
    where p.id_prod = p_idProduto;

    v_resultado := v_preco * p_quantidade;

    insert into item_pedido(id_item,id_ped,id_prod,quantidade,subtotal)
    values(p_idItem,p_idPedido,p_idProduto,p_quantidade,v_resultado);
commit;
end;
/


-- bloco 3: triggers (gatilhos automáticos)

-- questão 5: gatilho que faz a baixa de estoque na tabela produto após um pedido ser alterado para faturado
create or replace trigger tg_faturarPedido
after
update
on pedido
for each row
declare
    cursor c_itemPedido is
        select id_prod, quantidade
        from  item_pedido
        where i.id_ped = :new.id_ped;
begin

    if :new.status_pedido = 'FATURADO' then
            for ponteiro in c_itemPedido loop
                update produto p
                set qtd_estoque = qtd_estoque - ponteiro.quantidade
                where ponteiro.id_prod = :new.id_prod;
            end loop;
    end if;
end;
/

-- questão 6: gatilho que intercepta a inserção e força o subtotal correto antes de gravar no banco
create or replace trigger tg_Validasubtotal
before
insert
on item_pedido
for each row
declare
v_preco_un number(8,2) :=00.00;
begin

    select preco_unitario into v_preco_un
    from produto p where id_prod = :new.id_prod;

    :new.subtotal :=  v_preco_un * :new.quantidade;


end;
/