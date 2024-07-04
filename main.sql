create database vendas;

use vendas;

create table pessoas (
    pes_codigo int not null identity,
    pes_nome varchar(50) not null,
    pes_cpf varchar(12) not null unique,
    pes_status int check(pes_status in (1,2,3,4)),
    primary key (pes_codigo)
);

create table cliente (
    pes_codigo int not null primary key,
    cli_renda decimal(7,2),
    cli_credito decimal(7,2),
    foreign key(pes_codigo) references pessoas(pes_codigo)
);

create table estagiario (
    pes_codigo int not null primary key,
    est_bolsa decimal(7,2),
    check(est_bolsa >= 0),
    foreign key(pes_codigo) references pessoas(pes_codigo)
);

create table funcionarios (
    pes_codigo int not null primary key,
    fun_salario decimal(7,2),
    check(fun_salario > 0),
    sup_codigo int,
    foreign key(pes_codigo) references pessoas(pes_codigo), 
    foreign key(sup_codigo) references funcionarios(pes_codigo)
);

create table pedidos (
    ped_numero int not null identity,
    ped_data datetime, 
    ped_valor decimal(7,2),
    check(ped_valor > 0),
    ped_status int check(ped_status in (1,2,3,4)),
    func_codigo int not null,
    cli_codigo int not null,
    est_codigo int,
    foreign key(func_codigo) references funcionarios(pes_codigo),
    foreign key(cli_codigo) references cliente(pes_codigo),
    foreign key(est_codigo) references estagiario(pes_codigo),
    primary key(ped_numero)
);

create table produtos (
    prd_codigo int not null identity,
    prd_descricao varchar(50) not null, 
    prd_qtd int,
    prd_valor decimal(7,2),
    prd_status int check(prd_status in (1,2,3)), 
    primary key(prd_codigo)
);

create table itens_pedidos (
    ped_numero int not null,
    prd_codigo int not null,
    itp_qtd int not null, 
    primary key(ped_numero, prd_codigo),
    foreign key(ped_numero) references pedidos(ped_numero),
    foreign key(prd_codigo) references produtos(prd_codigo)
);

-- Inserts
insert into produtos values ('Lápis', 100, 0.8, 1);
insert into produtos values ('Apontador', 100, 2.5, 1);
insert into produtos values ('Caneta', 100, 1.2, 1);     
insert into produtos values ('Caderno', 100, 4.5, 1);
insert into produtos values ('Borracha', 100, 0.85, 1);

insert into pessoas values ('Batman', '3030', 1);
insert into pessoas values ('SuperMain', '1515', 1);
insert into pessoas values ('SpiderMan', '3131', 1);
insert into pessoas values ('Super Foca', '2020', 1);
insert into pessoas values ('Buslaboo', '007', 1);
insert into pessoas values ('BuschaGalack', '4343', 1);
insert into pessoas values ('Super Prof', '3636', 1);
insert into pessoas values ('Ensina Legal', '3333', 1);

insert into cliente values (1, 10000, 3000);
insert into cliente values (2, 15000, 5000);

insert into estagiario values (3, 725);
insert into estagiario values (5, 500);

insert into funcionarios values (4, 2500, null);
insert into funcionarios values (6, 1000, 4);
insert into funcionarios values (7, 2500, null);
insert into funcionarios values (8, 1050, 7);

insert into pedidos values ('2009-08-19 10:00', 1, 6, 1, 3, null);
insert into pedidos values ('2009-08-19 12:00', 1, 8, 2, 5, null);
insert into pedidos values ('2009-08-19 14:00', 1, 6, 1, 5, null);
insert into pedidos values ('2009-08-20 10:00', 1, 8, 1, 3, null);
insert into pedidos values ('2009-08-20 12:00', 1, 6, 2, 5, null);
insert into pedidos values ('2009-08-20 14:00', 1, 8, 2, 3, null);


select * from pedidos;

--  Total de cada pedido
SELECT ped_numero, SUM(ped_valor) AS valor_total
FROM pedidos
GROUP BY ped_numero;

-- Total vendido do produto 3 em cada pedido
SELECT ped_numero, SUM(itp_qtd) AS quantidade_vendida_produto_3
FROM itens_pedidos
WHERE prd_codigo = 3
GROUP BY ped_numero;

-- Pedidos com valor total acima de R$ 30,00 reais
SELECT ped_numero, SUM(ped_valor) AS valor_total_pedido
FROM pedidos
GROUP BY ped_numero
HAVING SUM(ped_valor) > 30.00;

--  Quantidade de itens por pedido
SELECT ped_numero, COUNT(*) AS quantidade_itens
FROM itens_pedidos
GROUP BY ped_numero;

-- Quantidade de vezes que cada produto foi vendido
SELECT prd_codigo, SUM(itp_qtd) AS quantidade_vendida
FROM itens_pedidos
GROUP BY prd_codigo;

-- Pedidos de cada cliente solicitou
SELECT cli_codigo, COUNT(*) AS quantidade_pedidos
FROM pedidos
GROUP BY cli_codigo;

-- Pedidos de cada funcionário
SELECT func_codigo, COUNT(*) AS quantidade_pedidos
FROM pedidos
GROUP BY func_codigo;

-- Pedidos que possuem mais do que 3 itens
SELECT ped_numero
FROM itens_pedidos
GROUP BY ped_numero
HAVING COUNT(*) > 3;

-- Produto mais vendido em quantidade de itens
SELECT TOP 1 prd_codigo, SUM(itp_qtd) AS quantidade_vendida
FROM itens_pedidos
GROUP BY prd_codigo
ORDER BY SUM(itp_qtd) DESC;

-- Pedidos (ped_numero, ped_data) que possuem mais do que 3 itens usando EXISTS
SELECT ped_numero, ped_data
FROM pedidos p
WHERE EXISTS (
    SELECT ped_numero
    FROM itens_pedidos
    WHERE ped_numero = p.ped_numero
    GROUP BY ped_numero
    HAVING COUNT(*) > 3
);

--  Pessoas que são clientes usando EXISTS
SELECT *
FROM pessoas p
WHERE EXISTS (
    SELECT 1
    FROM cliente c
    WHERE c.pes_codigo = p.pes_codigo
  );
