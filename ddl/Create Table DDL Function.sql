CREATE FUNCTION fn_Table_Structure (@InputSQL AS NVARCHAR(4000), @TableName AS NVARCHAR(128) = NULL) 
RETURNS NVARCHAR(4000)
AS
BEGIN

DECLARE @SQL AS NVARCHAR(4000)
DECLARE @name NVARCHAR(128)
DECLARE @is_nullable BIT 
DECLARE @system_type_name NVARCHAR(128)
DECLARE @collation_name NVARCHAR(128)
DECLARE @NewLine NVARCHAR(2) = CHAR(13) + CHAR(10) -- CRLF

DECLARE CUR_Table CURSOR LOCAL FAST_FORWARD
FOR
    SELECT  name ,
            is_nullable ,
            system_type_name ,
            collation_name
    FROM    sys.dm_exec_describe_first_result_set(@InputSQL, NULL, NULL)
    WHERE   is_hidden = 0
    ORDER BY column_ordinal ASC 

OPEN CUR_Table

FETCH NEXT FROM CUR_Table INTO @name, @is_nullable, @system_type_name,
    @collation_name

SET @SQL = 'CREATE TABLE [' + ISNULL(@TableName, 'TableName') + '] ('
    + @NewLine

WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL += @NewLine + '[' + @name + ']' + ' ' + @system_type_name
            + CASE WHEN @collation_name IS NOT NULL
                   THEN '  COLLATE ' + @collation_name + ' '
                   ELSE ''
              END + CASE WHEN @is_nullable = 0 THEN ' NOT NULL '
                         ELSE ''
                    END + ',' 
        FETCH NEXT FROM CUR_Table INTO @name, @is_nullable, @system_type_name,
            @collation_name
    END

SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + @NewLine + ')'

CLOSE CUR_Table
DEALLOCATE CUR_Table

RETURN @SQL
end 