
SELECT * FROM PYROPSQL.demo.pg_catalog.pg_tables

SELECT *
FROM OPENQUERY(PYROPSQL, 'select * from demo.pg_catalog.pg_tables') AS U2
