CREATE TABLE ##zzzindex (
	DatabaseName VARCHAR(250),
	IndexName VARCHAR(500),
	ObjectID_Name VARCHAR(500),
	IndexType VARCHAR(100)
)

---- USE DB HERE
INSERT INTO tempdb..##zzzindex
SELECT 
	DB_NAME() DatabaseName
	, name IndexName
	, OBJECT_NAME(object_id) ObjectID_Name
	, type_desc Indextype
FROM sys.indexes
WHERE object_id > 100
	AND type_desc <> 'HEAP'

SELECT *
FROM tempdb..##zzzindex

DROP TABLE tempdb..##zzzindex
