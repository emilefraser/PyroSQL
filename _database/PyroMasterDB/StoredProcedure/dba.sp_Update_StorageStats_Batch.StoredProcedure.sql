SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[sp_Update_StorageStats_Batch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[sp_Update_StorageStats_Batch] AS' 
END
GO

/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	-- RUNNING EVERYTHING FROM THE LOWEST LEVEL 
	-- ENSURE THAT LOWER ITEMS CAN JOIN TO HIGHER ITEMS WITH FOREIGN KEYS
	
	--	MACHINE_INSTANCE
	--	SQLSERVER_INSTANCE
	--	FILESIZE
	--	DATABASE
	--	DATABASE_FILE (data vs 
	--	SCHEMA
	--	TABLE 
	--	INDEXES
	
	EXEC master.dbo. sp_Update_StorageStats_Batch
*/
ALTER     PROCEDURE [dba].[sp_Update_StorageStats_Batch]
AS
BEGIN
	
	DECLARE 
		@StorageStats_BatchID INT = NULL
	,	@RC int = NULL

	-- If the table for Storage tracking doesnt exists, create it
	-- Also Assign BatchID to 1
	IF OBJECT_ID('dba.StorageStats_Batch', 'U') IS NULL
	BEGIN 

		  CREATE TABLE dba.[StorageStats_Batch](
			[BatchID]							[int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
			[HasStorageStatsRun_Machine]		[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Database]		[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_DatabaseFile]	[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Object]			[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Index]			[bit]				NOT NULL DEFAULT 0,
			[CreatedDT]							[datetime2](7)		NOT NULL DEFAULT GETDATE(),
			[UpdatedDT]							[datetime2](7)		NOT NULL DEFAULT GETDATE()
		) ON [PRIMARY]

	END	

	-- Create a Row with all default values
	INSERT INTO
		dba.StorageStats_Batch
	DEFAULT VALUES

	SET @StorageStats_BatchID = SCOPE_IDENTITY()
	--SELECT @StorageStats_BatchID

	-- VERY IMPORTANT, Run UPDATEUSAGE on EACH Database BEFORE Rest of the Procs are run
	EXEC sp_MSforeachdb 'DBCC UPDATEUSAGE (''?'') WITH NO_INFOMSGS;'
 
	-- LEVEL 0 = INDEXES 
	EXECUTE @RC = dba.sp_update_StorageStats_Index @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Index]	= 1 
		,	[UpdatedDT]					= GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 1 = OBJECT 
	EXECUTE @RC = dba.sp_Update_StorageStats_Object @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Object] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 2 = DBF 
	EXECUTE @RC = dba.sp_Update_StorageStats_DatabaseFile @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_DatabaseFile] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 3 = DB 
	EXECUTE @RC = dba.sp_Update_StorageStats_Database @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Database] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 4 = Machine Level 
	EXECUTE @RC = dba.sp_Update_StorageStats_Server @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Machine] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END
END




GO
