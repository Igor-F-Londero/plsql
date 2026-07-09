SET SERVEROUTPUT ON;

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

create or replace procedure pr_CriarPedido(
    p_idPedido in pedido.id_ped%type,
    p_idCliente in cliente.id_cli%type
)is
v_statusCliente varchar2(20);
begin

    select status_cliente  into v_statusCliente 
    from cliente c 
    where c.id_cli = p_idCliente;

    if v_statusCliente = 'BLOQUEADO' then
        raise_application_error(-20001, 'ERRO:  Cliente bloqueado');
    else
        insert into pedido(id_ped, id_cli, data_pedido,total_pedido)
        values (p_idPedido,p_idCliente,sysdate,0);
    end if;
end;
/

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

