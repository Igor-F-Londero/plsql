/* =========================================================
   BLOCO 1 - SEQUENCIA
   Gera os numeros dos pedidos: 1, 2, 3, 4...
   ========================================================= */

create sequence seq_pedidos
start with 1
increment by 1;


/* =========================================================
   BLOCO 2 - FUNCAO
   Conta os pedidos existentes para determinado produto.

   Retorna 0: nao existe pedido.
   Retorna 1 ou mais: ja existe pedido.
   ========================================================= */

create or replace function temPedido(
    p_codigoProduto number
)return number 
is
    quantidadePedidos number;
begin

    select count(*)
    into quantidadePedidos
    from Pedidos 
    where codigoProduto = p_codigoProduto;

    return quantidadePedidos;
end;
/


/* =========================================================
   BLOCO 3 - TRIGGER DE ENTRADA
   Depois de uma entrada, acrescenta a quantidade ao estoque.
   ========================================================= */

CREATE OR REPLACE TRIGGER atualizaEstoqueEntrada
AFTER INSERT ON Entradas
FOR EACH ROW
BEGIN
    UPDATE Produtos
    SET estoqueAtual = estoqueAtual + :NEW.quantidade
    WHERE codigoProduto = :NEW.codigoProduto;
END;
/


/* =========================================================
   BLOCO 4 - TRIGGER DE VENDA
   Depois de uma venda, retira a quantidade do estoque.
   ========================================================= */

CREATE OR REPLACE TRIGGER atualizaEstoqueVenda
AFTER INSERT ON Vendas
FOR EACH ROW
BEGIN
    UPDATE Produtos
    SET estoqueAtual = estoqueAtual - :NEW.quantidade
    WHERE codigoProduto = :NEW.codigoProduto;
END;
/


/* =========================================================
   BLOCO 5 - TRIGGER DE PEDIDO

   Quando o estoque muda:
   1. Verifica se ficou abaixo do minimo.
   2. Verifica se ainda nao existe pedido.
   3. Cria um pedido para completar o estoque minimo.
   ========================================================= */

CREATE OR REPLACE TRIGGER geraPedido
AFTER UPDATE OF estoqueAtual ON Produtos
FOR EACH ROW
BEGIN
    IF :NEW.estoqueAtual < :NEW.estoqueMinimo
       AND temPedido(:NEW.codigoProduto) = 0 THEN
        INSERT INTO Pedidos
        VALUES (
            seq_pedidos.NEXTVAL,
            :NEW.codigoProduto,
            :NEW.estoqueMinimo - :NEW.estoqueAtual
        );
    END IF;
END;
/
