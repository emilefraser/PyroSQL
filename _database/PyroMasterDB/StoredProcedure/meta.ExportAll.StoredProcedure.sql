SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[ExportAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[ExportAll] AS' 
END
GO

/*
	EXEC [meta].[ExportAll] 
				@WithData = 0

	EXEC [meta].[ExportAll] 
				@WithData = 0

	DECLARE @return_etl NVARCHAR(MAX) = ''
	DECLARE @FullObjectName SYSNAME = 'Number'
	EXEC [meta].[ExportData]
					 @table_name = @FullObjectName,
					 @schema_name = 'dbo',
					 @ommit_images = 1,
					 @return_etl =  @return_etl OUTPUT


	TODO: add more specific objecdts
	: add drop recreate 
	: add CREATE OR ALTER
*/

ALTER PROCEDURE [meta].[ExportAll] (
	@WithData    INT = 0
) 
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS ##ObjectChain;

	CREATE TABLE ##ObjectChain (
		[HID]         INT IDENTITY(1, 1) NOT NULL PRIMARY KEY
	  , [ObjectId]    INT
	  , [TYPE]        INT
	  , [OBJECTTYPE] AS CASE
							WHEN [TYPE] = 1
								THEN 'FN'
							WHEN [TYPE] = 4
								THEN 'V'
							WHEN [TYPE] = 8
								THEN 'U'
							WHEN [TYPE] = 16
								THEN 'P'
							WHEN [TYPE] = 128
								THEN 'R'
							WHEN [TYPE] = 256
								THEN 'T'
							WHEN [TYPE] = 2
								THEN 'SYSTEM'
							WHEN [TYPE] = 32
								THEN 'LOG'
							WHEN [TYPE] = 64
								THEN 'DF'
							WHEN [TYPE] = 1024
								THEN 'UDDT'
							WHEN [TYPE] = 1024
								THEN 'TRIGGER_VIEW_TABLE_PROCEDURE'
							WHEN [TYPE] = 1024
								THEN 'RULE_DEFAULT_DATATYPE'
							WHEN [TYPE] = 4606
								THEN 'NOTSYSTEM'
							WHEN [TYPE] = 4067
								THEN 'ALL'
							ELSE ''
						END
	  , [ONAME]       VARCHAR(255)
	  , [OOWNER]      VARCHAR(255)
	  , [SEQ]         INT
	 );

	--our results table
	DROP TABLE IF EXISTS [##Results];

	CREATE TABLE [##Results] (
		[ResultsID]      INT IDENTITY(1, 1) NOT NULL
	  , [ObjectType]	 VARCHAR(10) NULL
	  , [SchemaName]     SYSNAME NOT NULL DEFAULT 'dbo'
	  , [ObjectName]     SYSNAME NOT NULL
	  , [ResultsText]    VARCHAR(MAX)
	 );

	--our list of objects in dependancy order
	--exec sp_MSdependencies '?'
	INSERT INTO ##ObjectChain(
		[TYPE]
	  , [ONAME]
	  , [OOWNER]
	  , [SEQ]
	)
	EXEC [sp_msdependencies] 
		 @intrans = 1;


 --synonyns are object type 1 Function?!?!...gotta remove them
	UPDATE  
		##ObjectChain
	SET 
		[ObjectId] = OBJECT_ID([OOWNER] + '.' + [ONAME]);	
	
	DELETE FROM ##ObjectChain
	WHERE         
		[ObjectId] IN (
			SELECT 
				[object_id]
			FROM 
				[sys].[synonyms]
			UNION ALL
			SELECT 
				[object_id]
			FROM 
				[master].[sys].[synonyms]
		);

	DECLARE 
		@obj_cursor		   CURSOR
	  , @schemaname        VARCHAR(255)
	  , @objname           VARCHAR(255)
	  , @objecttype        VARCHAR(20)
	  , @FullObjectName    VARCHAR(510);

	SET @obj_cursor = CURSOR LOCAL FAST_FORWARD FOR 
		SELECT 
			[OOWNER]
		  , [ONAME]
		  , [OBJECTTYPE]
		FROM 
			##ObjectChain
		ORDER BY 
			[HID];

	OPEN @obj_cursor;
	FETCH NEXT FROM @obj_cursor INTO 
		@schemaname
	  , @objname
	  , @objecttype;

	DECLARE 
		@returnsql NVARCHAR(MAX) = '';

	WHILE(@@fetch_status = 0)
	BEGIN
		SET @FullObjectName = @schemaname + '.' + @objname;
		PRINT(CONCAT_WS('|', @FullObjectName, @objecttype));

		IF @objecttype = 'U'
		BEGIN

			EXEC [meta].[GetDDL] 
					 @TBL = @FullObjectName, 
					 @FINALSQL = @returnsql OUTPUT;

			INSERT INTO [##Results](
				[ObjectType]
			  , [SchemaName]  
			  , [ObjectName]   
			  ,	[ResultsText]
			)
			SELECT 
				[ObjectType]	= @objecttype
			,	[SchemaName]	= @schemaname
			,	[ObjectName]	= @objname
			,	[ResultText]	= @returnsql


			IF @WithData > 0
			BEGIN
				INSERT INTO [##Results](
					[ResultsText]
				)
				EXEC [sp_export_data]
					 @table_name = @FullObjectName,
					 @ommit_images = 1
			END;
		END;
			ELSE
		BEGIN

			IF @objecttype IN('V', 'FN', 'P', 'R', 'S', 'DF')--it's a FUNCTION/PROC/VIEW
			BEGIN
				--CREATE PROC/FUN/VIEW object needs a GO statement
				--INSERT INTO [##Results](
				--	[ResultsText]
				--)
				--SELECT
				--	'GO';


				--INSERT INTO [##Results](
				--	[ResultsText]
				--)
				--EXEC [sp_helptext]
				--	 @FullObjectName;

				INSERT INTO [##Results](
					[ObjectType]
				  , [SchemaName]  
				  , [ObjectName]   
				,	[ResultsText]
				)
				SELECT  
					[ObjectType]	= @objecttype
				,	[SchemaName]	= @schemaname
				,	[ObjectName]	= @objname
				,	[ResultText]	= smod.definition		
				FROM 
					[sys].[objects] AS [obj]
				INNER JOIN
					[sys].[schemas] AS [sch]
					ON [sch].schema_id = [obj].schema_id
				INNER JOIN
					[sys].[sql_modules] AS [smod]
					ON [smod].object_id = [obj].object_id
				WHERE [sch].[name] = @schemaname
					  AND [obj].[name] = @objname;

				--PRINT(@returnsql);
			END;
		END;

		FETCH NEXT FROM @obj_cursor INTO 
			@schemaname
		  , @objname
		  , @objecttype;
	END;

	SELECT 
	  [ObjectType]	
	  , [SchemaName]  
	  , [ObjectName]  
		,[ResultsText]
	FROM 
		[##Results]
	WHERE
		[ObjectName] LIKE '%Number%'
	ORDER BY 
		[ResultsID];
END;
GO
