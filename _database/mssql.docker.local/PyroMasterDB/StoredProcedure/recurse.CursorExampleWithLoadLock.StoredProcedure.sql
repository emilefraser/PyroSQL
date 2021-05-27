SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[CursorExampleWithLoadLock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [recurse].[CursorExampleWithLoadLock] AS' 
END
GO
/*	
	SELECT * FROM msdb.dbo.sysjobs
	EXEC [recurse].[CursorExampleWithLoadLock] 
									@Top = 10
								,	@AgentJobId = '1212D8A9-BB70-4ED0-A789-B9BCB1874D5C'
*/
ALTER   PROCEDURE [recurse].[CursorExampleWithLoadLock] (
	@Top		INT
,	@AgentJobId UNIQUEIDENTIFIER
)
AS
BEGIN

	-- DROP TABLE recurse.runs
	--CREATE TABLE recurse.runs (spid int, procid int, agentrunid int)

	--INSERT INTO recurse.runs(spid, procid)
	--SELECT @@SPID, @@procid
	
    DECLARE @URL NVARCHAR(MAX) = 'https://adaz-vpn-camsarch.azurewebsites.net/api/BLBTrigger?';
    DECLARE @Object AS INT;
    DECLARE @ErroMsg NVARCHAR(30)
    DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @sql_message AS NVARCHAR(MAX)
	
	-- Image parameters
	DECLARE @DocImageID AS VARCHAR(100)
    DECLARE @DocTrackID AS VARCHAR(100)     
    DECLARE @Image AS VARCHAR(MAX)      
	DECLARE @ImageXML AS VARCHAR(MAX)
    DECLARE @ContentType AS VARCHAR(100)    
    DECLARE @FileName AS VARCHAR(200)

	-- Request Parameters
    DECLARE @body AS VARCHAR(MAX)
    DECLARE @json NVARCHAR(MAX)

	-- Cursor
	DECLARE @CURSOR_DocImageIDs CURSOR

	-- For simpler transferbility
	-- CREATE ONLY ONCE
	--CREATE SYNONYM [DEV_DataVault__ODS_CAMS__DocImage] FOR [asset].[TestAssetLarge]
	--CREATE SYNONYM [dbo_DocImageArchive] FOR [asset].[TestAssetLargeArchive]

	-- Temp table to keep locked items
	-- DROP TABLE IF EXISTS ##LoadLock
	-- CREATE THIS ONLY ONCE ON PROC RUN.... 
	-- MOVE THIS TO BEFORE sp_executejob
	--CREATE TABLE ##LoadLock (LockId INT IDENTITY PRIMARY KEY, DocImageID BIGINT, JobId UNIQUEIDENTIFIER)
	--CREATE UNIQUE NONCLUSTERED INDEX ix_01 ON ##LoadLock (LockId) INCLUDE (DocImageID, JobId)

	-- Temp Table Variable
	DECLARE @RecordLock TABLE (
		[DocImageID] VARCHAR(100) PRIMARY KEY
	,	[DocTrackId] VARCHAR(100)
	,	[Image] NVARCHAR(MAX)
	,	[ContentType] VARCHAR(100)
	,	[FileName] VARCHAR(200)
	)

	-- Use (local) table Variable to both lock images and for the cursor
	INSERT INTO @RecordLock (
		[DocImageID]
	,	[DocTrackId]
	,	[Image]
	,	[ContentType]
	,	[FileName]
	)
	SELECT TOP(1000) 
			a.[DocImageID] 
		,	a.[DocTrackID]
		,	a.[Image]
		,	a.[ContentType]
		,	a.[FileName]		
		FROM 
			[DEV_DataVault__ODS_CAMS__DocImage] a 
		LEFT JOIN 
			[dbo_DocImageArchive] b 
			ON a.DocImageID = b.DocImageID 
		WHERE 
			b.[IsUploaded] IS NULL
		AND
			NOT EXISTS (
				SELECT 
					1
				FROM 
					##LoadLock AS ll
				WHERE
					ll.DocImageID = a.DocImageID
		)

	--SET @sql_message = 'Records to lock has been selected | ' + CONVERT(VARCHAR(20), GETDATE(), 121)	
	--RAISERROR(@sql_message,0 , 1) WITH NOWAIT

	-- INSERTS IMAGE IDS to LOAD LOCK
	INSERT INTO ##LoadLock (DocImageID, JobId)
	SELECT 
		DocImageID
	,	@AgentJobId
	FROM 
		@RecordLock AS rl
	WHERE
		NOT EXISTS (
			SELECT 
				1 
			FROM 
				##LoadLock AS ll
			WHERE
				ll.DocImageID = rl.DocImageID
	)


	--SET @sql_message = 'Records to lock inserted to ##LoadLock | ' + CONVERT(VARCHAR(20), GETDATE(), 121)
	--RAISERROR(@sql_message,0 , 1) WITH NOWAIT

	-- Cursor DECLARATION FROM @RecordLock... ONLY SELECTS NOT IN LOADLOCK
	-- USE THE @CURSOR_DocImages WITH LOCAL FAST_FORWARD HINT
    SET @CURSOR_DocImageIDs = CURSOR LOCAL FAST_FORWARD FOR 
		SELECT
			[DocImageID] 
		,	[DocTrackID]
		,	[Image]
		,	[ContentType]
		,	[FileName]		
		FROM 
			@RecordLock AS rl
		WHERE
			NOT EXISTS (
				SELECT 
					1 
				FROM 
					##LoadLock AS ll
				WHERE
					ll.DocImageID = rl.DocImageID
				AND
					ll.JobId != @AgentJobId
		)

	--SET @sql_message = 'Records inserted into @CURSOR_DocImageIDs| ' + CONVERT(VARCHAR(20), GETDATE(), 121)
	--RAISERROR(@sql_message,0 , 1) WITH NOWAIT

    OPEN @CURSOR_DocImageIDs
    FETCH NEXT FROM @CURSOR_DocImageIDs 
	INTO @DocImageID, @DocTrackID, @Image, @ContentType, @FileName

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        --DECLARE @URL NVARCHAR(MAX) = 'https://adaz-vpn-camsarch.azurewebsites.net/api/BLBTrigger?';
        --DECLARE @Object AS INT;
        --DECLARE @ErroMsg NVARCHAR(30)
        --DECLARE @ResponseText AS VARCHAR(8000);
		SET @ImageXML = (SELECT @Image FOR XML PATH)
		SET @body = '{
						"DocImageID": '  +  @DocImageID  + ',
						"DocTrackID": '  + @DocTrackID + ',
						"Image": "' +  @Image + '",
						"ContentType": "'+ @ContentType +'",
						"FileName": "'+ @FileName +'"
					}'

						
		--SET @sql_message = 'Record ready to send| ' + CONVERT(VARCHAR(20), GETDATE(), 121)
		--RAISERROR(@sql_message,0 , 1) WITH NOWAIT
		

        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'post',
                         @URL,
                         'false'
        EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
        EXEC sp_OAMethod @Object, 'send', null, @body
        EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
		

		-- FOR TESTING
		--SET @ResponseText = '{"Success":"1", "URL":"https://fake.fakeurl.fake"}'
		
		SET @sql_message = 'Record sent and responsetext received | ' + CONVERT(VARCHAR(20), GETDATE(), 121)
		--RAISERROR(@sql_message,0 , 1) WITH NOWAIT

        IF(@ResponseText != '')
        BEGIN

             SET @json  = @ResponseText

             IF((SELECT * FROM OPENJSON(@json) WITH (Success NVARCHAR(30) '$.Success')) = 1)
                BEGIN
                    INSERT INTO [dbo_DocImageArchive] (
						[DocImageID]
					,	[URL]
					,	[UploadedDate]
					,	[IsUploaded]
					)
                    SELECT 
						STR(@DocImageID)
					,	[URL]
					,	GETDATE()
					,	1
                    FROM 
						OPENJSON(@json)
                    WITH (
                        [URL] NVARCHAR(150) '$.URL'
					);

					
					SET @sql_message = 'Record marked as processed success | ' + CONVERT(VARCHAR(20), GETDATE(), 121)
					--RAISERROR(@sql_message,0 , 1) WITH NOWAIT
                END
                ELSE
                BEGIN
                    SET @ErroMsg  = 'Failed to Upload'

					SET @sql_message = 'Record upload failed | ' + CONVERT(VARCHAR(20), GETDATE(), 121)
					--RAISERROR(@sql_message,0 , 1) WITH NOWAIT
                END
        END
        ELSE
        BEGIN
             SET @ErroMsg = 'No data found.';
             Print @ErroMsg;
        END

        FETCH NEXT FROM @CURSOR_DocImageIDs 
		INTO @DocImageID, @DocTrackID, @Image, @ContentType, @FileName
    END

	DELETE
		ll
	FROM
		##LoadLock AS ll
	WHERE ll.JobId = @AgentJobID
	AND EXISTS (
		SELECT 
			1
		FROM 
			@RecordLock AS rl
		WHERE
			rl.DocImageID = ll.DocImageID
	)

END
GO
