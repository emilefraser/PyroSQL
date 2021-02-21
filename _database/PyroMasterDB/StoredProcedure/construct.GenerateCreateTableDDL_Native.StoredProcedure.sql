SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[GenerateCreateTableDDL_Native]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[GenerateCreateTableDDL_Native] AS' 
END
GO
ALTER   PROCEDURE [construct].[GenerateCreateTableDDL_Native] 
@Identifier NVARCHAR(776)

/**
summary:   >
This procedure returns an object buld script as a single-row, single column
result. 
Unlike the built-in OBJECT_DEFINITION, it also does tables.
It copies the SMO style where possible but it uses the more intuitive
eay of representing referential constrants and includes the documentation
as comments that was, for unknown reasons, left out by microsoft.
You call it with the name of the table, either as a string, a valid table name,
or as a schema-qualified table name in a string.
Author: Phil Factor
Revision: 1.1 dealt properly with heaps
date: 20 Apr 2010
example:
     - code: sp_ScriptFor 'production.TransactionHistory'
example:
     - code: sp_ScriptFor 'HumanResources.vEmployee'
example:
     - code: execute phone..sp_ScriptFor 'holidays'
example:
     - code: execute AdventureWorks..sp_ScriptFor TransactionHistory
example:
     - code: sp_ScriptFor 'HumanResources.uspUpdateEmployeeHireInfo'
returns:   >
single row, single column result Build_Script.
**/
--sp_helptext sp_help 'jobcandidate'

AS
DECLARE @Script VARCHAR(MAX)
DECLARE	@dbname	SYSNAME
DECLARE @PrimaryKeyBuild VARCHAR(MAX)
IF CHARINDEX ('.',@identifier)=0 
	SELECT @Identifier=QUOTENAME(Object_Schema_name(s.object_id))
	          +'.'+QUOTENAME(s.name)
	FROM sys.objects s WHERE s.name LIKE @identifier

SELECT @dbname = PARSENAME(@identifier,3)
	IF @dbname IS NULL
		SELECT @dbname = DB_NAME()
	ELSE IF @dbname <> DB_NAME()
		BEGIN
			RAISERROR(15250,-1,-1)
			RETURN(1)
		END

SELECT @Script=object_definition(OBJECT_ID(@Identifier))
IF @script IS NULL
	IF (SELECT TYPE FROM sys.objects 
	    WHERE object_id=OBJECT_ID(@Identifier))
      IN ('U','S')--if it is a table
		BEGIN
		SELECT @Script='/*'+CONVERT(VARCHAR(2000),value)+'*/
'       FROM  sys.extended_properties ep
			WHERE ep.major_ID = OBJECT_ID(@identifier) 
			AND  minor_ID=0 AND class=1

SELECT @Script=COALESCE(@Script,'')+'CREATE TABLE '+@Identifier+'(
   ' +
(SELECT    QUOTENAME(c.name)+ ' '+ t.name+' '
       + CASE WHEN is_computed=1 THEN ' AS '+ --do DDL for a computed column
			(SELECT definition FROM sys.computed_columns cc 
			 WHERE cc.object_id=c.object_id AND cc.column_ID=c.column_ID)
             + CASE WHEN 
					    (SELECT is_persisted FROM sys.computed_columns cc 
				         WHERE cc.object_id=c.object_id 
				         AND cc.column_ID=c.column_ID)
                    =1 THEN 'PERSISTED' ELSE '' END
              --we may have to put in the length          
              WHEN t.name IN ('char', 'varchar','nchar','nvarchar') THEN '('+
		   CASE WHEN c.max_length=-1 THEN 'MAX' 
		        ELSE CONVERT(VARCHAR(4),
		                     CASE WHEN t.name IN ('nchar','nvarchar') 
		                     THEN  c.max_length/2 ELSE c.max_length END ) 
		        END +')' 
		WHEN t.name IN ('decimal','numeric') 
		        THEN '('+ CONVERT(VARCHAR(4),c.precision)+','
		                + CONVERT(VARCHAR(4),c.Scale)+')'
		        ELSE '' END 
		+ CASE WHEN is_identity=1  THEN 'IDENTITY ('
			+ CONVERT(VARCHAR(8),IDENT_SEED(Object_Schema_Name(c.object_id)
			+'.'+OBJECT_NAME(c.object_id)))+','
			+ CONVERT(VARCHAR(8),IDENT_INCR(Object_Schema_Name(c.object_id)
			+'.'+OBJECT_NAME(c.object_id)))+')' ELSE '' END
		+ CASE WHEN c.is_rowguidcol=1 THEN ' ROWGUIDCOL' ELSE '' END
		+ CASE WHEN XML_collection_ID<>0 THEN --deal with object schema names
					'('+ CASE WHEN is_XML_Document=1 
					            THEN 'DOCUMENT ' ELSE 'CONTENT ' END 
                     + COALESCE(
                         (SELECT QUOTENAME(ss.name)+'.' +QUOTENAME(sc.name) 
                          FROM sys.xml_schema_collections sc 
                          INNER JOIN  Sys.Schemas ss 
                              ON sc.schema_ID=ss.schema_ID
                          WHERE sc.xml_collection_ID=c.XML_collection_ID)
                       ,'NULL')
                     +')' ELSE '' END
		+ CASE WHEN  is_identity=1 
		    THEN CASE WHEN OBJECTPROPERTY(object_id, 'IsUserTable') = 1
			       AND COLUMNPROPERTY(object_id, c.name, 'IsIDNotForRepl') = 0
                   AND OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
                THEN '' ELSE ' NOT FOR REPLICATION ' END ELSE '' END
		+ CASE WHEN c.is_nullable=0 THEN ' NOT NULL' ELSE ' NULL' END
		+ CASE WHEN c.default_object_id <>0 
		   THEN ' DEFAULT '+object_Definition(c.default_object_id) ELSE '' END
		+ CASE WHEN c.collation_name IS NULL THEN ''
		   WHEN  c.collation_name<>
			     (SELECT collation_name FROM sys.databases 
			        WHERE name=DB_NAME()) COLLATE Latin1_General_CI_AS 
		   THEN COALESCE(' COLLATE '+c.collation_name,'') ELSE '' END+'|,|'
		+ CASE WHEN ep.value IS NOT NULL 
		   THEN ' /*'+CAST(value AS VARCHAR(100))+ '*/' ELSE '' END
		+ CHAR(10)+'   '
		

		FROM sys.columns c INNER JOIN sys.types t 
			ON c.user_Type_ID=t.user_Type_ID
		LEFT OUTER JOIN sys.extended_properties ep
			ON c.object_id = ep.major_ID  
			     AND c.column_ID = minor_ID AND class=1
		LEFT OUTER JOIN 
		(SELECT 'REFERENCES ' 
           +COALESCE(SCHEMA_NAME(fkc.referenced_object_id)+'.','')
           +OBJECT_NAME(fkc.referenced_object_id)+'('+c.name+') '--+
              + CASE WHEN delete_referential_action_desc <> 'NO_ACTION' 
			           THEN 'ON DELETE ' 
			              + REPLACE(delete_referential_action_desc,'_',' ') 
			                                       COLLATE database_default 
			           ELSE '' END
			  + CASE WHEN update_referential_action_desc <> 'NO_ACTION' 
			           THEN 'ON UPDATE ' 
			              + REPLACE(update_referential_action_desc,'_',' ') 
			                                       COLLATE database_default 
			           ELSE '' END 
			  AS reference, parent_column_id
			FROM sys.foreign_key_columns fkc
			INNER JOIN sys.foreign_keys fk ON constraint_object_id=fk.object_ID
			INNER JOIN sys.columns c 
			ON c.object_ID = fkc.referenced_object_id 
			    AND c.column_ID = referenced_column_id 
			 WHERE fk.parent_object_ID = OBJECT_ID(@identifier)
			AND constraint_object_ID NOT IN --include only single-column keys
                    (SELECT 1 FROM sys.foreign_key_columns multicolumn
			          WHERE multicolumn.parent_object_id =fk.parent_object_ID
			          GROUP BY constraint_object_id
			          HAVING COUNT(*)>1)) column_references
	    ON  column_references.parent_column_ID=c.column_ID
        WHERE object_id = OBJECT_ID(@identifier)
        ORDER BY c.column_ID
		FOR XML PATH(''))--join up all the rows!
		
		SELECT @Script=LEFT(@Script,LEN(@Script)-1)
				--take out the trailing line feed
		
		SELECT TOP 1 @PrimaryKeyBuild=  '
CONSTRAINT ['+i.name+'] PRIMARY KEY '
			+CASE WHEN type_desc='CLUSTERED' THEN 'CLUSTERED' ELSE '' END+' 
   (
	   '	+ COALESCE(SUBSTRING((SELECT ','+COL_NAME(ic.object_id,ic.column_id)
		FROM  sys.index_columns AS ic 
		WHERE ic.index_ID=i.index_ID AND ic.object_id=i.object_id
		ORDER BY key_ordinal
		FOR XML PATH('')),2,2000),'?')+'
   )WITH (PAD_INDEX  = '
        +CASE WHEN is_Padded<>0 THEN 'ON' ELSE 'OFF' END 
        +',  IGNORE_DUP_KEY = '
            +CASE WHEN ignore_dup_key<>0 THEN 'ON' ELSE 'OFF' END 
        +', ALLOW_ROW_LOCKS  = '
            +CASE WHEN allow_row_locks<>0 THEN 'ON' ELSE 'OFF' END 
        +', ALLOW_PAGE_LOCKS  = '
            +CASE WHEN allow_page_locks<>0 THEN 'ON' ELSE 'OFF' END 
        +') ON [PRIMARY]'+
		+ CASE WHEN ep.value IS NOT NULL THEN '
  /*'+CAST(value AS VARCHAR(100))+'*/' ELSE '' END
		FROM sys.indexes i 
		LEFT OUTER JOIN sys.extended_properties ep
			ON i.object_id = ep.major_ID  AND i.index_ID = minor_ID AND class=7 
		WHERE OBJECT_NAME(object_id)=PARSENAME(@identifier,1)  
		     AND is_primary_key =1
		--and add the primary key build script and the ON PRIMARY, deleting the 
		--  last comma-line-terminator if necessary. conver the |,| to commas
		--     
		IF @PrimaryKeyBuild IS NULL
			SELECT @Script=STUFF(@Script,--delete final comma line-terminator
			             LEN(@Script)-CHARINDEX('|,|',
			             REVERSE(@Script)+'|')-1,3
			             ,'')
		SELECT @Script=REPLACE(@Script,'|,|',',')+COALESCE(@PrimaryKeyBuild,'')+'
) ON [PRIMARY]'
END
SELECT COALESCE(@Script,'-- could not find '''+@identifier+''' in '+DB_NAME(),'null identifier.') 
    AS Build_Script
GO
