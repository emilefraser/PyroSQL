USE [DataManager_2020723]
GO
/****** Object:  StoredProcedure [DATADICT].[sp_populate_XmlApplicationObjectModel]    Script Date: 2020/07/26 12:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC sp_configure 'show advanced options', 1;  
--RECONFIGURE;
--GO 
--EXEC sp_configure 'Ad Hoc Distributed Queries', 1;  
--RECONFIGURE;  
--GO

-- EXEC MASTER.[sp_import_GlStructure]
CREATE OR ALTER   PROCEDURE MASTER.[sp_import_GlStructure]
AS
BEGIN
BEGIN TRY
  
DECLARE 
	@sql_statement			NVARCHAR(MAX)
,	@sql_message			NVARCHAR(MAX)
,	@sql_parameter			NVARCHAR(MAX)
,	@sql_crlf				NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab				NVARCHAR(1) = CHAR(9)
,	@sql_debug				BIT = 1
,	@sql_execute			BIT = 1


DECLARE 
	@xmldoc					XML
,	@intdoc					INT
,	@file_path				NVARCHAR(100)				= 'D:\Customers\General Ledger\Import'
,	@extention				NVARCHAR(10)				= '.csv'
,	@currentID				INT							= 1
,	@currentFile			NVARCHAR(512)				= ''
,	@currentFileType		NVARCHAR(128)				= ''
,	@applicationname		VARCHAR(100) 
,	@applicationid			SMALLINT 

--Xp_dirtree has three parameters: 
--directory – This is the directory you pass when you call the stored procedure; for example ‘D:Backup’.
--depth  – This tells the stored procedure how many subfolder levels to display.  The default of 0 will display all subfolders.
--file – This will either display files as well as each folder.  The default of 0 will not display any files.


DROP TABLE IF EXISTS ##DirectoryTree

CREATE TABLE ##DirectoryTree (
	[ID]				INT IDENTITY(1, 1)
,	[Directory]			NVARCHAR(512) NULL
,	[FileName]			NVARCHAR(512) NULL
,	[Depth]				INT NULL
,	[IsFile]			BIT NULL
,	[FileType]			VARCHAR(50) NULL
)

INSERT INTO ##DirectoryTree (
	[FileName]
,	[depth]
,	[isfile]
)

EXEC master.sys.xp_dirtree
	 @file_path
,	2
,	1



DELETE FROM ##DirectoryTree WHERE [FileName] NOT LIKE '%' + @extention + '%'

UPDATE ##DirectoryTree
SET 
	[Directory] = @file_path

UPDATE ##DirectoryTree
SET [FileType] = CASE  
					WHEN REPLACE([FileName], @extention, '') = 'Financial Reporting Hierarchy - Income Statement' THEN 'FRHIS'
					WHEN REPLACE([FileName], @extention, '') = 'FInancial Reporting Hierarchy - Balance Sheet' THEN 'FRHBS'
					ELSE 'Other'
				END


--CLEAR TABLE FIRST 
TRUNCATE TABLE MASTER.ReportingHierarchyItem



-- START LOOPING THROUGH THE ITEMS
WHILE (@currentID <= (SELECT MAX([ID]) FROM ##DirectoryTree))
BEGIN


	SET @currentFile = (SELECT [Directory] + '\' + [FileName] FROM ##DirectoryTree WHERE [ID] = @currentID)
	SET @currentFileType = (SELECT [FileType] FROM ##DirectoryTree WHERE [ID] = @currentID)

	--SELECT @currentID, @currentFile, @currentFile

	SET @sql_statement = '
	BULK INSERT MASTER.ReportingHierarchyItem
	FROM 
		''' + @currentFile + '''
	WITH (
		FORMAT = ''CSV'',
		MAXERRORS = 1,
		FIRSTROW = 2,
        FIELDTERMINATOR = '';'',
        ROWTERMINATOR = ''\n'',
		BATCHSIZE = 5000
		--FIRE_TRIGGERS
		--TABLOCK
      )
	  '
	SET @sql_parameter = ''

	IF (@sql_debug = 1)
	BEGIN
		RAISERROR (@sql_statement, 0 , 1) WITH NOWAIT
	END

	IF (@sql_execute= 1)
	BEGIN
		EXEC sp_executesql 
			@stmt = @sql_statement
		,	@param = @sql_parameter
	END

	SET @currentID += 1

END

DROP TABLE IF EXISTS ##DirectoryTree
END TRY

BEGIN CATCH
	;THROW
	DROP TABLE IF EXISTS ##DirectoryTree
END CATCH


END
	/*

SELECT * 
FROM OPENROWSET(
        BULK 'D:\Customers\General Ledger\GL\FInancial Reporting Hierarchy - Balance Sheet.csv',
        FORMAT = 'CSV',
        FIRSTROW = 1
    )
WITH (
    [country_code] VARCHAR (5) COLLATE Latin1_General_BIN2 1,
    [population] bigint 4
) AS [r]

SELECT
*
FROM OPENROWSET(
	BULK 'D:\Customers\General Ledger\GL\FInancial Reporting Hierarchy - Balance Sheet.csv', 
	FORMAT = 'CSV',
	FIRSTROW = 2
)
WITH (
	[ReportingHierarchyItemID] [int] 1,
	[ItemCode] [varchar](50) 2,
	[ItemName] [varchar](100) 3,
	[ReportingHierarchyTypeID] INT 4,
	[ParentItemID] [int] 5,
	[CompanyID] [int] 6,
	[ReportingHierarchySortOrder] INT 7
) AS [r]



SELECT
*
FROM OPENROWSET(
	BULK 'D:\Customers\General Ledger\GL\FInancial Reporting Hierarchy - Balance Sheet.csv',
	FORMAT = 'CSV',
	FIRSTROW = 1
) AS DATA


SELECT * FROM OPENROWSET('MSDASQL',

'Driver={Microsoft Text Driver (*.txt; *.csv)};

DefaultDir=D:\Customers\General Ledger\GL\;',

'SELECT * FROM FInancial Reporting Hierarchy - Balance Sheet.csv')

GO

------------

 

--Using a different provider

SELECT *

FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',

'Text;Database=D:\Customers\General Ledger\GL\;HDR=YES',

'SELECT * FROM FInancial Reporting Hierarchy - Balance Sheet.csv')

GO

/*
BULK INSERT
   { database_name.schema_name.table_or_view_name | schema_name.table_or_view_name | table_or_view_name }
      FROM 'data_file'
     [ WITH
    (
   [ [ , ] BATCHSIZE = batch_size ]
   [ [ , ] CHECK_CONSTRAINTS ]
   [ [ , ] CODEPAGE = { 'ACP' | 'OEM' | 'RAW' | 'code_page' } ]
   [ [ , ] DATAFILETYPE =
      { 'char' | 'native'| 'widechar' | 'widenative' } ]
   [ [ , ] DATA_SOURCE = 'data_source_name' ]
   [ [ , ] ERRORFILE = 'file_name' ]
   [ [ , ] ERRORFILE_DATA_SOURCE = 'data_source_name' ]
   [ [ , ] FIRSTROW = first_row ]
   [ [ , ] FIRE_TRIGGERS ]
   [ [ , ] FORMATFILE_DATA_SOURCE = 'data_source_name' ]
   [ [ , ] KEEPIDENTITY ]
   [ [ , ] KEEPNULLS ]
   [ [ , ] KILOBYTES_PER_BATCH = kilobytes_per_batch ]
   [ [ , ] LASTROW = last_row ]
   [ [ , ] MAXERRORS = max_errors ]
   [ [ , ] ORDER ( { column [ ASC | DESC ] } [ ,...n ] ) ]
   [ [ , ] ROWS_PER_BATCH = rows_per_batch ]
   [ [ , ] ROWTERMINATOR = 'row_terminator' ]
   [ [ , ] TABLOCK ]

   -- input file format options
   [ [ , ] FORMAT = 'CSV' ]
   [ [ , ] FIELDQUOTE = 'quote_characters']
   [ [ , ] FORMATFILE = 'format_file_path' ]
   [ [ , ] FIELDTERMINATOR = 'field_terminator' ]
   [ [ , ] ROWTERMINATOR = 'row_terminator' ]
    )]
*/ 



/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [DataManager_2020723].[MASTER].[ReportingHierarchyItem]
  */