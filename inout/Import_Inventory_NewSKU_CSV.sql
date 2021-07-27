DECLARE @FILE_LOAD_PATH AS VARCHAR(255) = 'E:\CoreBI\GoogleDrive\1_RawData\InvMaster_Hierarchy\'
DECLARE @IS_HDR AS VARCHAR(3) = 'YES'
DECLARE @CHARSET INT = '65001'
DECLARE @FILE_NAME VARCHAR (255) = 'Morne.csv'
DECLARE @sql AS NVARCHAR(MAX) 

IF OBJECT_ID('tempdb..##inventoryLoadCSV') IS NOT NULL DROP TABLE ##inventoryLoadCSV

SET @sql = 
'
SELECT * 
INTO ##inventoryLoadCSV
FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
''Text;Database='+@FILE_LOAD_PATH+';HDR='+@IS_HDR+';CharacterSet=65001;'',
''SELECT * FROM '+@FILE_NAME+''')
'
print(@sql)
EXECUTE(@sql)


INSERT INTO [InvMasterHierarchy]
(
	[Stock Code]
,	[Business]
,	[Brand Name]
,	[LOB]
,	[SUB LOB]
,	[Capacity]
,	[ScreenSize]
,	[Network Type]
,	[Type]
,	[Colour]
,	[Description]
)
SELECT
	[StockCode]
,	[BrandName]
,	[Business]
,	[LOB]
,	[SUB_LOB]
,	[Capacity]
,	[ScreenSize]
,	[Network_Type]
,	[Type]
,	[Colour]
,	[Description]
FROM
	[##inventoryLoadCSV] AS new
WHERE NOT EXISTS
(
	SELECT * FROM [InvMasterHierarchy] AS imh
	WHERE imh.[Stock Code] = new.StockCode
)



INSERT INTO [InvMasterStatus]
(
	[Stock Code]
,	[Status]
)
SELECT
	[StockCode]
,	[Status]
FROM
	[##inventoryLoadCSV] AS new
WHERE NOT EXISTS
(
	SELECT * FROM [InvMasterStatus] AS imh
	WHERE imh.[Stock Code] = new.StockCode
)



INSERT INTO [InvMasterStatus]
(
	[Stock Code]
,	[Status]
)
SELECT
	[Stock Code]
,	'Active'
FROM
	[InvMasterHierarchy] AS new
WHERE NOT EXISTS
(
	SELECT * FROM [InvMasterStatus] AS imh
	WHERE imh.[Stock Code] = new.[Stock Code]
)



IF OBJECT_ID('tempdb..##inventoryLoadCSV') IS NOT NULL DROP TABLE ##inventoryLoadCSV
