SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
	DECLARE @BatchID INT = 1
	EXEC STORE.sp_Update_StorageStats_DatabaseFile @BatchID
*/
CREATE     PROCEDURE [STORE].[sp_Update_StorageStats_DatabaseFile]
			@BatchID INT
AS
BEGIN

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('STORE.StorageStats_DatabaseFile', 'U') IS NULL
	BEGIN 
		CREATE TABLE STORE.[StorageStats_DatabaseFile](
			[StorageStats_DatabaseFileID] [int] NULL,
			[BatchID] [int] NULL,
			[file_id] INT NULL,
			[file_guid] UNIQUEIDENTIFIER NULL,
			[file_name] NVARCHAR(128) NULL,	
			[file_type] INT NULL,
			[file_type_desc] VARCHAR(128) NULL,
			[file_classification] varchar(128) NULL,
			[file_path] NVARCHAR(MAX) NULL,
			[file_drive] NVARCHAR(10) NULL,
			[size_file] BIGINT NULL,
			[max_size]	BIGINT NULL,
			[growth] BIGINT NULL,
			[database_id] [int] NOT NULL,
			[SqlServerInstanceName] [sysname] NULL,
			[MachineName]  [sysname] NULL,
			[CreatedDT] [datetime2](7) NOT NULL DEFAULT GETDATE()
		)

	END

	INSERT INTO STORE.[StorageStats_DatabaseFile]
	(
       [BatchID]
      ,[file_id]
      ,[file_guid]
      ,[file_name]
      ,[file_type]
      ,[file_type_desc]
	  ,[file_classification]
      ,[file_path]
      ,[file_drive]
      ,[size_file]
	  ,[max_size]
	  ,[growth]
      ,[database_id]
      ,[SqlServerInstanceName]
      ,[MachineName]
      ,[CreatedDT]
	)
	SELECT 
		@BatchID
	,	m.file_id
	,	m.file_guid
	,	m.name
	,	m.type
	,	m.type_desc
	,	CASE	WHEN DB_NAME(m.database_id) = 'tempdb' THEN 'tempdb'
				WHEN m.Type_Desc = 'LOG'  THEN 'log'
				ELSE 'data'
		END AS file_classification
	,	m.physical_name
	,	SUBSTRING(m.physical_name, 1, CHARINDEX(':', m.physical_name))
	,	(m.size * 8) AS size_file
	,	m.max_size
	,	m.growth
	,	m.database_id
	,	CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) AS SqlServerInstanceName
	,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS MachineName
	,	GETDATE() AS CreatedDT
	FROM 
		sys.databases AS d
	INNER JOIN 
		sys.master_files AS m
	ON 
		m.database_id = d.database_id 
	ORDER BY 
		m.physical_name	

END

GO
