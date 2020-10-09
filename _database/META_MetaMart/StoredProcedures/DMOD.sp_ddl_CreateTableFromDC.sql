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

--Sample Execution: [INTEGRATION].sp_ddl_CreateTable 1
CREATE PROCEDURE [DMOD].[sp_ddl_CreateTableFromDC]
@DDLScript VARCHAR(MAX) OUTPUT ,
@DataEntityID INT,
@TargetDataBaseName VARCHAR(50)
AS

--DECLARE @DDLScript VARCHAR(MAX)
--DECLARE @DataEntityID INT = 47500
--DECLARE @TargetDataBaseName VARCHAR(50) = 'StageArea'

--TODO Insert logic to generate the Create Table statement for the @DataEntityID passed in

--Sample logic
--create table [EMPLOYEE] ([MST_SQ] int, [EMP_EMPNO] varchar(20), [TITLE_CODEID] smallint, [EMP_SURNAME] varchar(25), [EMP_INITIALS] varchar(6), [EMP_FIRSTNAME] varchar(20), [EMP_ID] varchar(16), [GC_CODEID] smallint, [EMP_CONTRACTOR] smallint, [ERS_CODEID] smallint, [OC_CODEID] smallint, [DPT_CODEID] smallint, [GNG_CODEID] smallint, [CC_CODEID] smallint, [EMP_ENGAGE] datetime, [EMP_DISCHARGE] datetime, [DR_CODEID] smallint, [PCAT_CODEID] smallint, [PRUL_CODEID] smallint, [CYC_CODEID] smallint, [EMP_CYCLEDAY] smallint, [ENV_CODEID] smallint, [EMP_PAYRATE] decimal(10, 2), [RM_CODEID] smallint, [EMP_INHERITTRG] smallint, [ERCAT_CODEID] smallint, [EMP_CALLOUT] smallint, [EMP_BIRTHDATE] datetime, [EMP_TERMMSG] varchar(30), [VPT_CODEID] smallint, [WL_CODEID] smallint, [HRD_CODEID] smallint, [EMP_UNIVERSALID] varchar(100), [EMP_ISGUARD] smallint, [EMP_ISDRIVER] smallint,
--[HOLCAT_CODEID] smallint
--)

--Test Execution:
--EXEC sp_CreateTableFromDC 'Employee', 'dbo'


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
								
DECLARE @Sql1 VARCHAR(MAX)
DECLARE @Sql2 VARCHAR(MAX)
DECLARE @Sql3 VARCHAR(MAX)

SET @Sql1 = ('IF (NOT EXISTS (SELECT name 
						     FROM ['+@TargetDataBaseName+'].sys.schemas 
						     WHERE name = '''+@Schema+'''
							  )
				 )
				BEGIN
					USE '+@TargetDataBaseName+'
						BEGIN
							EXEC(''CREATE SCHEMA ['+@Schema+']'')
						END
				END
				' + char(13) + char(13))
		


SET @Sql2 = (SELECT DISTINCT 'IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@TargetDataBaseName) + '.sys.tables AS t INNER JOIN ' + QUOTENAME(@TargetDataBaseName) + '.sys.schemas AS s ON t.schema_id = s.schema_id WHERE s.name = ''' + @Schema + ''' AND t.name = ''' + @InTable + ''')' + CHAR(13) + ' BEGIN ' + CHAR(13) + '

CREATE TABLE'+' ['+@TargetDataBaseName+'].[' + @Schema+'].'+'['+ @InTable + '] (' + o.list + ')' 
		  	 FROM    DC.DataEntity de
			 CROSS APPLY
				(SELECT 
					'['+FieldName+'] ' + 
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

				  FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
				  ORDER BY FieldSortOrder asc
				  FOR XML PATH('')
				    ) o (list)
					LEFT JOIN DC.Field f ON
					f.DataEntityID = de.DataEntityID
					   AND f.IsPrimaryKey  = 1

				  WHERE de.DataEntityID = @DataEntityID
				  
	
				)

SET @sql3 = CHAR(13) + ' END'

set @DDLScript = @Sql1+@Sql2+@sql3
select @DDLScript

--TODO Remove from this section and create "call" proc to execute this [INTEGRATION].[sp_ddl_CreateTableFromDC] and [INTEGRATION].[sp_ins_DDLExecutionItem] (modular design)
--EXEC [INTEGRATION].[sp_ins_DDLExecutionItem]
--	@SqlText = 'CREATE TABLE [StageArea].[XT].TestTable (TestTableID INT, TestTableName VARCHAR(100))',
--	@QueryDescription = 'Test table creation in StageArea database',
--	@TargetDatabaseInstanceID = 1




/* 
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- Old code from Karl

ALTER PROCEDURE [INTEGRATION].[sp_ddl_CreateTableFromDC]
	@DataEntityID INT
AS

--TODO Insert logic to generate the Create Table statement for the @DataEntityID passed in

--Sample logic
--create table [EMPLOYEE] ([MST_SQ] int, [EMP_EMPNO] varchar(20), [TITLE_CODEID] smallint, [EMP_SURNAME] varchar(25), [EMP_INITIALS] varchar(6), [EMP_FIRSTNAME] varchar(20), [EMP_ID] varchar(16), [GC_CODEID] smallint, [EMP_CONTRACTOR] smallint, [ERS_CODEID] smallint, [OC_CODEID] smallint, [DPT_CODEID] smallint, [GNG_CODEID] smallint, [CC_CODEID] smallint, [EMP_ENGAGE] datetime, [EMP_DISCHARGE] datetime, [DR_CODEID] smallint, [PCAT_CODEID] smallint, [PRUL_CODEID] smallint, [CYC_CODEID] smallint, [EMP_CYCLEDAY] smallint, [ENV_CODEID] smallint, [EMP_PAYRATE] decimal(10, 2), [RM_CODEID] smallint, [EMP_INHERITTRG] smallint, [ERCAT_CODEID] smallint, [EMP_CALLOUT] smallint, [EMP_BIRTHDATE] datetime, [EMP_TERMMSG] varchar(30), [VPT_CODEID] smallint, [WL_CODEID] smallint, [HRD_CODEID] smallint, [EMP_UNIVERSALID] varchar(100), [EMP_ISGUARD] smallint, [EMP_ISDRIVER] smallint,
--[HOLCAT_CODEID] smallint
--)

--Test Execution:
--EXEC sp_CreateTableFromDC 'Employee', 'dbo'

	declare @InTable VARCHAR(100) = 'Employee' --,
	declare @Schema VARCHAR(100) = 'dbo'

DECLARE @Sql VARCHAR(MAX)

SET @Sql = (
	select  'create table XT.' +  + '[' + @Schema + '_' + @InTable + '] (' + o.list + ')' --+ CASE WHEN tc.Constraint_Name IS NULL THEN '' ELSE 'ALTER TABLE ' + so.Name + ' ADD CONSTRAINT ' + tc.Constraint_Name  + ' PRIMARY KEY ' + ' (' + LEFT(j.List, Len(j.List)-1) + ')' END
	from    sysobjects so
	cross apply
		(SELECT 
			'['+column_name+'] ' + 
			data_type + case data_type
				when 'sql_variant' then ''
				when 'text' then ''
				when 'ntext' then ''
				when 'xml' then ''
				when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
				else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','') end --+ ' ' +
			--case when exists ( 
			--select id from syscolumns
			--where object_name(id)=so.name
			--and name=column_name
			--and columnproperty(id,name,'IsIdentity') = 1 
			--) then
			--'IDENTITY(' + 
			--cast(ident_seed(so.name) as varchar) + ',' + 
			--cast(ident_incr(so.name) as varchar) + ')'
			--else ''
			--end
			--+ ' ' +
	  --       (case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 'NULL ' + 
	  --        case when information_schema.columns.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT '+ information_schema.columns.COLUMN_DEFAULT ELSE '' END
			+ ', ' 

		 from information_schema.columns where table_name = so.name
		 order by ordinal_position
		FOR XML PATH('')) o (list)
	left join
		information_schema.table_constraints tc
	on  tc.Table_name       = so.Name
	AND tc.Constraint_Type  = 'PRIMARY KEY'
	--cross apply
	--    (select '[' + Column_Name + '], '
	--     FROM   information_schema.key_column_usage kcu
	--     WHERE  kcu.Constraint_Name = tc.Constraint_Name
	--     ORDER BY
	--        ORDINAL_POSITION
	--     FOR XML PATH('')) j (list)
	where   xtype = 'U' AND table_name = @InTable
	AND name    NOT IN ('dtproperties')
)


SET @Sql = @Sql + SUBSTRING(@Sql, 1, LEN(@Sql) - 1)

--EXEC @Sql
SELECT @Sql






--TODO Remove from this section and create "call" proc to execute this [INTEGRATION].[sp_ddl_CreateTableFromDC] and [INTEGRATION].[sp_ins_DDLExecutionItem] (modular design)
--EXEC [INTEGRATION].[sp_ins_DDLExecutionItem]
--	@SqlText = 'CREATE TABLE [StageArea].[XT].TestTable (TestTableID INT, TestTableName VARCHAR(100))',
--	@QueryDescription = 'Test table creation in StageArea database',
--	@TargetDatabaseInstanceID = 1

*/

GO
