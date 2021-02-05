declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Current Size MB] int, [Used Space MB] int, [Free Space MB] float, Type int)

INSERT INTO @sptable
EXEC sp_MSforeachdb
'
USE [?];
SELECT 
	db_name() as ''Database Name''
,	name AS ''File Name''
,	physical_name AS ''Physical Name''
,	size/128 AS ''Total Size in MB''
,	cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int) AS UsedSpaceMB
,	size/128.0 - cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int)  AS ''Available Space In MB''
,	type
FROM sys.database_files



'

SELECT
	[Database Name]
  , CASE
		WHEN Type = 0
			THEN 'ROWS'
		WHEN Type = 1
			THEN 'LOG'
		WHEN Type = 2
			THEN 'FILESTREAM'
		WHEN Type = 3
			THEN 'Not supported'
		WHEN Type = 4
			THEN 'FULL-TEXT'
	END AS 'Type'
  , [File Name]
  , [Physical Name]
  , [Current Size MB]
  , [Used Space MB]
  , [Free Space MB]
FROM
	@sptable
--WHERE Type =0
--and [Physical Name] LIKE 'F%'
ORDER BY
	[Database Name] ASC
  , Type			DESC
  , [Free Space MB] DESC


  

SELECT DB_NAME(vfs.DbId) DatabaseName, mf.name,
mf.physical_name, vfs.BytesRead, vfs.BytesWritten,
vfs.IoStallMS, vfs.IoStallReadMS, vfs.IoStallWriteMS,
vfs.NumberReads, vfs.NumberWrites,
(Size*8)/1024 Size_MB
FROM ::fn_virtualfilestats(NULL,NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.DbIaa
d
AND mf.FILE_ID = vfs.FileId
GO


SELECT * 
FROM 
	::fn_virtualfilestats(NULL,NULL) AS fvfs
INNER JOIN 
	sys.master_files AS mf 
	ON mf.database_id = fvfs.DbId
INNER JOIN 
	sys.database_files AS dbf
	ON mf.file_id = dbf.file_id
	AND dbf.name = mf.name

