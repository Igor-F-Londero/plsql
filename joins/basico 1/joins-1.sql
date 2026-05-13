-- A query mais básica: junta PEDIDOS com CLIENTES para mostrar quem fez cada pedido

--Pedidos com nome do cliente
    SELECT p.id_pedido, c.nome ,c.cidade, p.data_pedido, p.status FROM pedidos p
    JOIN clientes c ON c.id_cliente = p.id_cliente ORDER BY p.data_pedido DESC;
    --sempre usar alias de tabela (p,c) com joins o codigo fica ilegivel sem eles

--Junta PRODUTOS com CATEGORIAS. Todo produto tem uma categoria (FK obrigatória), então INNER JOIN não perde dados

    SELECT p.id_produto, p.nome,p.estoque,p.preco AS produto, c.nome AS categoria
    FROM produtos p 
    JOIN categorias c ON c.id_categoria= p.id_categoria ORDER BY c.nome, p.nome;

-- LEFT JOIN mantém todos os clientes, mesmo os que nunca compraram( a tabela da esquerda aparece sempre.Campos da direita ficam null se não houver match)
--clientes com ou sem pedidos -
SELECT c.nome, c.email, COUNT(p.id_pedido) AS total_pedidos, MAX(p.data_pedido) ultima_compra
    FROM clientes c 
    LEFT JOIN pedidos p ON p.id_cliente=c.id_cliente
    GROUP BY c.nome, c.email ORDER BY total_pedidos DESC;


