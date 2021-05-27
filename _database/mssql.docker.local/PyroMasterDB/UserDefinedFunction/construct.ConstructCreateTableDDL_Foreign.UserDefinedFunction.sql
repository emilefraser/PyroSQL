SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[ConstructCreateTableDDL_Foreign]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
moto_sales moto_mktg_mtd
	
	DECLARE @ddl NVARCHAR(MAX) = ''''
	SELECT  @ddl = [construct].[ConstructCreateTableDDL_Foreign](''demo'', ''moto_mktg'',''campaigns'', 1)
	SELECT @ddl

	TODO: Add type converter
*/
CREATE   FUNCTION [construct].[ConstructCreateTableDDL_Foreign] (
	@DatabaseName		SYSNAME = NULL
,	@SchemaName			SYSNAME = ''dbo''
,	@TableName			SYSNAME
,	@IsDropAndRecreate	BIT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE 
	@sql_statement NVARCHAR(MAX)
,	@sql_statement_column NVARCHAR(MAX)
,	@sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10) 
,	@sql_tab NVARCHAR(2) = CHAR(9)

-- DROP IF EXISTS 
IF(@IsDropAndRecreate = 1)
BEGIN
	SET @sql_statement  = ''IF EXISTS ('' +  @sql_crlf + @sql_tab +
						  ''SELECT 1 '' + @sql_crlf + @sql_tab +
						  ''FROM '' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName) + '')'' + @sql_crlf

	SET @sql_statement += ''DROP TABLE '' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName) + '';'' + @sql_crlf + @sql_crlf
END

-- CREATE TABLE STATEMENT
SET @sql_statement += ''CREATE TABLE '' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName) + '' ('' + @sql_crlf + @sql_tab

-- ADD COLUMNS
;WITH cte AS (
	SELECT 
			QUOTENAME(column_name) + '' '' + data_type + '' ''
		+ IIF(is_identity = ''YES'', ''IDENTITY(1, 1)'','''')
		+ IIF(is_nullable = ''YES'', ''NULL'', ''NOT NULL'')
		+ IIF(column_default IS NOT NULL, ''DEFAULT '' + CONVERT(NVARCHAR(MAX), column_default), '''')
		+ IIF(MAX(col.ordinal_position) OVER (ORDER BY col.ordinal_position DESC) = col.ordinal_position , CHAR(13) + CHAR(10) + '')'', CHAR(13) + CHAR(10) + '','' + CHAR(9)) AS col_string
		, col.ordinal_position
	FROM 
		demo.dbo.pg_columns AS col
	WHERE 
		table_catalog = ''demo''
	AND 
		table_schema = ''moto_mktg''
	AND 
		table_name =  ''campaigns'' 
)
SELECT @sql_statement += cte.col_string
FROM cte
ORDER BY ordinal_position


RETURN @sql_statement 

/*

DECLARE @abc NVARCHAR(MAX) = ''''
--SELECT @abc = @abc + t1.col_string + '','' 

SELECT @abc += t1.col_string_new --t1.col_string
--@abc + IIF(t1.ordinal_position = MAX(t1.ordinal_position) OVER (ORDER BY t1.ordinal_position DESC), t1.col_string  + '')'', t1.col_string  + '','') 
FROM (
SELECT
	 QUOTENAME(column_name) + '' '' + data_type + '' ''
	+ IIF(is_identity = ''YES'', ''IDENTITY(1, 1)'','''')
	+ IIF(is_nullable = ''YES'', ''NULL'', ''NOT NULL'')
	+ IIF(column_default IS NOT NULL, ''DEFAULT '' + CONVERT(NVARCHAR(MAX), column_default), '''') 
	+ IIF(col.ordinal_position = 5, CHAR(13) + CHAR(10) + '')'','','' + CHAR(13) + CHAR(10) + CHAR(9)) AS col_string
,	col.ordinal_position
,	 IIF(MAX(col.ordinal_position) OVER (ORDER BY col.ordinal_position DESC) = col.ordinal_position ,1,0) AS isMax
,QUOTENAME(column_name) + '' '' + data_type + '' ''
	+ IIF(is_identity = ''YES'', ''IDENTITY(1, 1)'','''')
	+ IIF(is_nullable = ''YES'', ''NULL'', ''NOT NULL'')
	+ IIF(column_default IS NOT NULL, ''DEFAULT '' + CONVERT(NVARCHAR(MAX), column_default), '''') 
	+ IIF(MAX(col.ordinal_position) OVER (ORDER BY col.ordinal_position DESC) = col.ordinal_position , CHAR(13) + CHAR(10) + '')'','','' + CHAR(13) + CHAR(10) + CHAR(9)) AS col_string_new




FROM demo.dbo.pg_columns AS col
	WHERE col.table_catalog = ''demo''
	AND col.table_schema = ''moto_mktg''
	AND col.table_name =  ''campaigns'' 
) AS t1
LEFT JOIN (
SELECT
	 QUOTENAME(column_name) + '' '' + data_type + '' ''
	+ IIF(is_identity = ''YES'', ''IDENTITY(1, 1)'','''')
	+ IIF(is_nullable = ''YES'', ''NULL'', ''NOT NULL'')
	+ IIF(column_default IS NOT NULL, ''DEFAULT '' + CONVERT(NVARCHAR(MAX), column_default), '''') AS col_string,
	col.ordinal_position
FROM demo.dbo.pg_columns AS col
	WHERE col.table_catalog = ''demo''
	AND col.table_schema = ''moto_mktg''
	AND col.table_name =  ''campaigns'' 
) AS t2
ON t2.ordinal_position + 1 = t1.ordinal_position
order by t1.ordinal_position

SELECT @abc


   '' +
(SELECT    QUOTENAME(c.name)+ '' ''+ t.name+'' ''
       + CASE WHEN is_computed=1 THEN '' AS ''+ --do DDL for a computed column
			(SELECT definition FROM sys.computed_columns cc 
			 WHERE cc.object_id=c.object_id AND cc.column_ID=c.column_ID)
             + CASE WHEN 
					    (SELECT is_persisted FROM sys.computed_columns cc 
				         WHERE cc.object_id=c.object_id 
				         AND cc.column_ID=c.column_ID)
                    =1 THEN ''PERSISTED'' ELSE '''' END
              --we may have to put in the length          
              WHEN t.name IN (''char'', ''varchar'',''nchar'',''nvarchar'') THEN ''(''+
		   CASE WHEN c.max_length=-1 THEN ''MAX'' 
		        ELSE CONVERT(VARCHAR(4),
		                     CASE WHEN t.name IN (''nchar'',''nvarchar'') 
		                     THEN  c.max_length/2 ELSE c.max_length END ) 
		        END +'')'' 
		WHEN t.name IN (''decimal'',''numeric'') 
		        THEN ''(''+ CONVERT(VARCHAR(4),c.precision)+'',''
		                + CONVERT(VARCHAR(4),c.Scale)+'')''
		        ELSE '''' END 
		+ CASE WHEN is_identity=1  THEN ''IDENTITY (''
			+ CONVERT(VARCHAR(8),IDENT_SEED(Object_Schema_Name(c.object_id)
			+''.''+OBJECT_NAME(c.object_id)))+'',''
			+ CONVERT(VARCHAR(8),IDENT_INCR(Object_Schema_Name(c.object_id)
			+''.''+OBJECT_NAME(c.object_id)))+'')'' ELSE '''' END
		+ CASE WHEN c.is_rowguidcol=1 THEN '' ROWGUIDCOL'' ELSE '''' END
		+ CASE WHEN XML_collection_ID<>0 THEN --deal with object schema names
					''(''+ CASE WHEN is_XML_Document=1 
					            THEN ''DOCUMENT '' ELSE ''CONTENT '' END 
                     + COALESCE(
                         (SELECT QUOTENAME(ss.name)+''.'' +QUOTENAME(sc.name) 
                          FROM sys.xml_schema_collections sc 
                          INNER JOIN  Sys.Schemas ss 
                              ON sc.schema_ID=ss.schema_ID
                          WHERE sc.xml_collection_ID=c.XML_collection_ID)
                       ,''NULL'')
                     +'')'' ELSE '''' END
		+ CASE WHEN  is_identity=1 
		    THEN CASE WHEN OBJECTPROPERTY(object_id, ''IsUserTable'') = 1
			       AND COLUMNPROPERTY(object_id, c.name, ''IsIDNotForRepl'') = 0
                   AND OBJECTPROPERTY(object_id, ''IsMSShipped'') = 0
                THEN '''' ELSE '' NOT FOR REPLICATION '' END ELSE '''' END
		+ CASE WHEN c.is_nullable=0 THEN '' NOT NULL'' ELSE '' NULL'' END
		+ CASE WHEN c.default_object_id <>0 
		   THEN '' DEFAULT ''+object_Definition(c.default_object_id) ELSE '''' END
		+ CASE WHEN c.collation_name IS NULL THEN ''''
		   WHEN  c.collation_name<>
			     (SELECT collation_name FROM sys.databases 
			        WHERE name=DB_NAME()) COLLATE Latin1_General_CI_AS 
		   THEN COALESCE('' COLLATE ''+c.collation_name,'''') ELSE '''' END+''|,|''
		+ CASE WHEN ep.value IS NOT NULL 
		   THEN '' /*''+CAST(value AS VARCHAR(100))+ ''*/'' ELSE '''' END
		+ CHAR(10)+''   ''
		

		FROM sys.columns c INNER JOIN sys.types t 
			ON c.user_Type_ID=t.user_Type_ID
		LEFT OUTER JOIN sys.extended_properties ep
			ON c.object_id = ep.major_ID  
			     AND c.column_ID = minor_ID AND class=1
		LEFT OUTER JOIN 
		(SELECT ''REFERENCES '' 
           +COALESCE(SCHEMA_NAME(fkc.referenced_object_id)+''.'','''')
           +OBJECT_NAME(fkc.referenced_object_id)+''(''+c.name+'') ''--+
              + CASE WHEN delete_referential_action_desc <> ''NO_ACTION'' 
			           THEN ''ON DELETE '' 
			              + REPLACE(delete_referential_action_desc,''_'','' '') 
			                                       COLLATE database_default 
			           ELSE '''' END
			  + CASE WHEN update_referential_action_desc <> ''NO_ACTION'' 
			           THEN ''ON UPDATE '' 
			              + REPLACE(update_referential_action_desc,''_'','' '') 
			                                       COLLATE database_default 
			           ELSE '''' END 
			  AS reference, parent_column_id
			FROM sys.foreign_key_columns fkc
			INNER JOIN sys.foreign_keys fk ON constraint_object_id=fk.object_ID
			INNER JOIN sys.columns c 
			ON c.object_ID = fkc.referenced_object_id 
			    AND c.column_ID = referenced_column_id 
			 WHERE fk.parent_object_ID = OBJECT_ID(@TableName)
			AND constraint_object_ID NOT IN --include only single-column keys
                    (SELECT 1 FROM sys.foreign_key_columns multicolumn
			          WHERE multicolumn.parent_object_id =fk.parent_object_ID
			          GROUP BY constraint_object_id
			          HAVING COUNT(*)>1)) column_references
	    ON  column_references.parent_column_ID=c.column_ID
        WHERE object_id = OBJECT_ID(@TableName)
        ORDER BY c.column_ID
		FOR XML PATH(''''))--join up all the rows!
		
		SELECT @sql_statement=LEFT(@sql_statement,LEN(@sql_statement)-1)
				--take out the trailing line feed
		
		SELECT TOP 1 @PrimaryKeyBuild=  ''
CONSTRAINT [''+i.name+''] PRIMARY KEY ''
			+CASE WHEN type_desc=''CLUSTERED'' THEN ''CLUSTERED'' ELSE '''' END+'' 
   (
	   ''	+ COALESCE(SUBSTRING((SELECT '',''+COL_NAME(ic.object_id,ic.column_id)
		FROM  sys.index_columns AS ic 
		WHERE ic.index_ID=i.index_ID AND ic.object_id=i.object_id
		ORDER BY key_ordinal
		FOR XML PATH('''')),2,2000),''?'')+''
   )WITH (PAD_INDEX  = ''
        +CASE WHEN is_Padded<>0 THEN ''ON'' ELSE ''OFF'' END 
        +'',  IGNORE_DUP_KEY = ''
            +CASE WHEN ignore_dup_key<>0 THEN ''ON'' ELSE ''OFF'' END 
        +'', ALLOW_ROW_LOCKS  = ''
            +CASE WHEN allow_row_locks<>0 THEN ''ON'' ELSE ''OFF'' END 
        +'', ALLOW_PAGE_LOCKS  = ''
            +CASE WHEN allow_page_locks<>0 THEN ''ON'' ELSE ''OFF'' END 
        +'') ON [PRIMARY]''+
		+ CASE WHEN ep.value IS NOT NULL THEN ''
  /*''+CAST(value AS VARCHAR(100))+''*/'' ELSE '''' END
		FROM sys.indexes i 
		LEFT OUTER JOIN sys.extended_properties ep
			ON i.object_id = ep.major_ID  AND i.index_ID = minor_ID AND class=7 
		WHERE OBJECT_NAME(object_id)=PARSENAME(@TableName,1)  
		     AND is_primary_key =1
		--and add the primary key build script and the ON PRIMARY, deleting the 
		--  last comma-line-terminator if necessary. conver the |,| to commas
		--     
		IF @PrimaryKeyBuild IS NULL
			SELECT @sql_statement=STUFF(@sql_statement,--delete final comma line-terminator
			             LEN(@sql_statement)-CHARINDEX(''|,|'',
			             REVERSE(@sql_statement)+''|'')-1,3
			             ,'''')
		SELECT @sql_statement=REPLACE(@sql_statement,''|,|'','','')+COALESCE(@PrimaryKeyBuild,'''')+''
) ON [PRIMARY]''
END
SELECT COALESCE(@sql_statement,''-- could not find ''''''+@TableName+'''''' in ''+DB_NAME(),''null identifier.'') 
    AS Build_Script
*/
END' 
END
GO
