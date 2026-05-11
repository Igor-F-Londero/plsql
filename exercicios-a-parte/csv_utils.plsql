-- Recuperar e baixa um arquivo CSV como um CLOB diretamente da web
-- e retorná-lo como tabela com uma única instrução:

SELECT * FROM TABLE(csv_util_pkg.clob_to_csv(httpuritype('http://www.foo.example/bar.csv').getclob()
)
);


-- Fazer um INSERT direto usando INSERT .. SELECT
INSERT INTO my_table (frist_column,second_column)
SELECT c001, c002
FROM TABLE(csv_util_pkg.clob_to_csv(
httpuritype('http://www.foo.example/bar.csv').getclob()
)
);

--Usar SQL para filtrar os resultados
-- (embora isso possa impactar a performance)

SELECT * FROM TABLE(csv_util_pkg.clob_to_csv(
httpuritype('http://www.foo.example/bar.csv').getclob()
)
)
WHERE C002 = 'Chevy';

-- Fazer isso de forma mais procedural

CREATE TABLE x_dump(
    clob_value clob,
    dump_date date DEFAULT sysdate,
    dump_id number
);

DECLARE
    I_clob clob;
    cursor I_cursor IS
    SELECT csv.* FROM X_dump d, TABLE (csv_util_pkg.clob_to_csv(d.clob_value)) csv WHERE d.dump_id = 1;

BEGIN
    I_clob := httpuritype(
    'http://www.foo.example/bar.csv'
    ).getclob();

    INSERT INTO x_dump (clob_value,dump_id) VALUES(I_clob, 1);

COMMIT;

    dbms_lob.freetemporary(l_clob);

    for l_rec in l_cursor loop
    dbms_output.put_line(
    'linha ' || l_rec.line_number ||
    ', coluna 1 = ' || l_rec.c001
    );
end loop;
END;
/
