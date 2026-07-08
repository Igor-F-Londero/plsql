CREATE TABLE produto (
    id_prod NUMBER PRIMARY KEY,
    nome_produto VARCHAR2(100) NOT NULL,
    preco_unitario NUMBER(8,2) NOT NULL,
    qtd_estoque NUMBER NOT NULL
);

CREATE TABLE cliente (
    id_cli NUMBER PRIMARY KEY,
    nome_cliente VARCHAR2(100) NOT NULL,
    status_cliente VARCHAR2(20) DEFAULT 'ATIVO' -- 'ATIVO', 'BLOQUEADO'
);

CREATE TABLE pedido (
    id_ped NUMBER PRIMARY KEY,
    id_cli NUMBER NOT NULL,
    data_pedido DATE NOT NULL,
    total_pedido NUMBER(8,2) DEFAULT 0.00,
    status_pedido VARCHAR2(20) DEFAULT 'PAGAMENTO_PENDENTE', -- 'PAGAMENTO_PENDENTE', 'FATURADO', 'CANCELADO'
    FOREIGN KEY (id_cli) REFERENCES cliente(id_cli)
);

CREATE TABLE item_pedido (
    id_item NUMBER PRIMARY KEY,
    id_ped NUMBER NOT NULL,
    id_prod NUMBER NOT NULL,
    quantidade NUMBER NOT NULL,
    subtotal NUMBER(8,2) NOT NULL,
    FOREIGN KEY (id_ped) REFERENCES pedido(id_ped),
    FOREIGN KEY (id_prod) REFERENCES produto(id_prod)
);


-- Carga de Produtos
INSERT INTO produto VALUES (10, 'Notebook Dell', 4500.00, 15);
INSERT INTO produto VALUES (20, 'Mouse Sem Fio', 150.00, 50);
INSERT INTO produto VALUES (30, 'Monitor 24 LG', 1200.00, 8);

-- Carga de Clientes
INSERT INTO cliente VALUES (1, 'Ana Silva', 'ATIVO');
INSERT INTO cliente VALUES (2, 'Carlos Souza', 'BLOQUEADO');

-- Carga de Pedidos
INSERT INTO pedido VALUES (501, 1, TO_DATE('07/07/2026 10:00:00', 'DD/MM/YYYY HH24:MI:SS'), 4800.00, 'FATURADO');
INSERT INTO pedido VALUES (502, 1, TO_DATE('08/07/2026 09:00:00', 'DD/MM/YYYY HH24:MI:SS'), 1200.00, 'PAGAMENTO_PENDENTE');

-- Carga de Itens de Pedido
INSERT INTO item_pedido VALUES (1001, 501, 10, 1, 4500.00);
INSERT INTO item_pedido VALUES (1002, 501, 20, 2, 3000.00);
INSERT INTO item_pedido VALUES (1003, 502, 30, 1, 1200.00);
COMMIT;