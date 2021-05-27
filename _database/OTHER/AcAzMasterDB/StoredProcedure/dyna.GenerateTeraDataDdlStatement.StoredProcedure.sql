SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dyna].[GenerateTeraDataDdlStatement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dyna].[GenerateTeraDataDdlStatement] AS' 
END
GO
/*
{{META>}}
	{Written By}	Emile Fraser
	{CreatedDate}	2021-01-22
	{UpdatedDate}	2021-01-22
	{Description}	Creates a Dynamic TeraData DDL Statement

	{Usage>}		
					EXEC dyna.GenerateTeraDataDdlStatement
	{<Usage}
{{<META}}
*/
ALTER   PROCEDURE [dyna].[GenerateTeraDataDdlStatement]
AS
BEGIN

-- User-defined variables --
DECLARE 
      @tableName            NVARCHAR(128)   = 'dbo.example_table'
    , @TeradataDatabase     VARCHAR(30)     = 'mufford'
    , @TeradataTable        VARCHAR(30)     = NULL -- Will generate if you leave NULL


-- Script-defined variables -- 

DECLARE @columnList TABLE (columnID INT);
DECLARE @TeradataTableName VARCHAR(60);

IF @TeradataTable IS NULL
    SET @TeradataTableName = @TeradataDatabase + '.tmp_' + SUBSTRING(@tableName,PATINDEX('%.%',@tableName)+1,26);
ELSE 
    SET @TeradataTableName = @TeradataDatabase + '.' + @TeradataTable;

DECLARE 
      @schemaStatement      NVARCHAR(MAX) = 'CREATE TABLE ' + @TeradataTableName + '('
    , @currentID            INT
    , @firstID              INT;

INSERT INTO @columnList
SELECT column_id 
FROM sys.columns 
WHERE object_id = OBJECT_ID(@tableName)
ORDER BY column_id;

SELECT @firstID = MIN(columnID) FROM @columnList;

WHILE EXISTS(SELECT * FROM @columnList)
BEGIN

    SELECT @currentID = MIN(columnID) FROM @columnList;

    IF @currentID <> @firstID
    BEGIN
        SELECT 
            @schemaStatement = @schemaStatement + ',';
    END

    SELECT @schemaStatement = @schemaStatement + '"' + c.name + '" ' 
        + CASE 
            WHEN t.name = 'BIT'                             THEN 'BYTEINT'
            WHEN t.name = 'TINYINT'                         THEN 'SMALLINT'
            WHEN t.name = 'UNIQUEIDENTIFIER'                THEN 'CHAR(38)'
            WHEN t.name = 'DATETIME'                        THEN 'TIMESTAMP(3)'
            WHEN t.name = 'MONEY'                           THEN 'DECIMAL(18,4)'
            WHEN t.name = 'XML'                             THEN 'CLOB'
            WHEN t.name IN ('SMALLDATETIME', 'DATETIME2')   THEN 'TIMESTAMP(0)'
            WHEN t.name IN ('NVARCHAR','NCHAR')
                THEN SUBSTRING(t.name, 2, 10) + '(' + CAST(c.max_length / 2 AS VARCHAR(4)) + ') CHARACTER SET UNICODE NOT CASESPECIFIC'
            WHEN t.name IN ('VARCHAR','CHAR')
                THEN t.name + '(' + CAST(c.max_length AS VARCHAR(4)) + ')'
            ELSE t.name
        END
        + CASE
            WHEN c.is_nullable = 1 THEN ' NULL'
            ELSE ' NOT NULL'
        END
    FROM sys.columns    AS c
    JOIN sys.types      AS t
        ON c.system_type_id = t.system_type_id
    WHERE c.object_id = OBJECT_ID(@tableName)
        AND c.column_id = @currentID;

    DELETE FROM @columnList WHERE columnID = @currentID;

END;

SELECT @schemaStatement + ');' AS 'Execute this statement in Teradata to create the table:'

END
GO
