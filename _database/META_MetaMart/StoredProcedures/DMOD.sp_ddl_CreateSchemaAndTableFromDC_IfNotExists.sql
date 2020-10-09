SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Francois Senekal
-- Create Date: 19 Oct 2018
-- Description: Creates DDL from a DataEntity ID.
-- =============================================
-- =======================================================================================================================================
-- Version Control
-- Editor:      Francois Senekal
-- =======================================================================================================================================

--Sample Execution: [INTEGRATION].sp_ddl_CreateTable 46743
CREATE PROCEDURE [DMOD].[sp_ddl_CreateSchemaAndTableFromDC_IfNotExists]
@DDLScript VARCHAR(MAX) OUTPUT ,
@DataEntityID INT,
@TargetDataBaseName VARCHAR(50)
AS 


DECLARE @InTable VARCHAR(100) = 
								(SELECT TOP 1 DataEntityName 
									FROM dc.dataentity
									WHERE dataentityid = @DataEntityID) 
DECLARE @Schema VARCHAR(100) =  (SELECT TOP 1 SchemaName 
									FROM dc.[Schema] s
									INNER JOIN dc.[DataEntity]de ON
										de.SchemaID = s.SchemaID
									WHERE dataentityid = @DataEntityID)
DECLARE @Database VARCHAR(100) =  (SELECT TOP 1 DatabaseName
									FROM DC.[Database] db
									INNER JOIN  dc.[Schema] s ON
										s.databaseid = db.databaseid
									INNER JOIN dc.[DataEntity]de ON
										de.SchemaID = s.SchemaID
									WHERE dataentityid = @DataEntityID)
								
DECLARE @Sql VARCHAR(MAX)
DECLARE @Sql1 VARCHAR(MAX)

SET @Sql = ('IF (NOT EXISTS (SELECT name 
						     FROM sys.schemas 
						     WHERE name = '''+@Schema+'''
							  )
				 )
				BEGIN
					EXEC(''CREATE SCHEMA ['+@Schema+']'')
				END
				
				')
		
	
	SET @Sql1 = (SELECT 'IF OBJECT_ID(''[' + @Schema+ '].'+'['+ @InTable + ']'', ''U'') IS NULL
				 CREATE TABLE ['+@TargetDataBaseName+'].[' + @Schema+'].'+'['+ @InTable + '] (' + o.list + ')' 
		  		 FROM    DC.DataEntity de
				 CROSS APPLY
					(SELECT 
						'['+f.FieldName+'] ' + 
						DataType + CASE DataType
							WHEN 'int' THEN ''
							WHEN 'real' THEN ''
							WHEN 'geography' THEN ''
							WHEN 'uniqueidentifier' THEN ''
							WHEN 'image' THEN ''
							WHEN 'tinyint' THEN ''
							WHEN 'bigint' THEN ''
							WHEN 'bit' THEN ''
							WHEN 'smallint' THEN ''
							WHEN 'numeric' THEN '(' + cast([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
							WHEN 'decimal' THEN '(' + cast([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
							WHEN 'datetime' THEN ''
							WHEN 'date' THEN ''
							WHEN 'datetime2' THEN '(7)'
 							ELSE coalesce('('+CASE WHEN [MaxLength] = -1 THEN 'MAX' ELSE cast([MaxLength] AS VARCHAR) END +')','') END +
								CASE 
									 WHEN FieldName = 'BKHash' THEN ' NOT NULL,'
									 WHEN FieldName like 'HK_%' THEN ' NOT NULL,'
									 WHEN FieldName like 'LINKHK_%' THEN ' NOT NULL,'
									 ELSE ' NULL,'
								END 
								--+ CHAR(13)
								--select	*
					  FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
					  ORDER BY FieldSortOrder asc
					  FOR XML PATH('')
						) o (list)
						--left JOIN DC.Field field ON
						--field.DataEntityID = de.DataEntityID
						--   AND field.IsPrimaryKey  = 1
					  WHERE de.DataEntityID = @DataEntityID
				  
	
				)

--select	@Sql1

set @DDLScript = @Sql+@Sql1

GO
