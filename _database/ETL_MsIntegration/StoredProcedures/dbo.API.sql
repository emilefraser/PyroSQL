SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE API @Url VARCHAR(8000),
	@Method VARCHAR(5)				= 'GET',--POST
	@BodyData NVARCHAR(MAX)			= NULL,--normally json object string : '{"key":"value"}',
	@Authorization VARCHAR(8000)	= NULL,--Basic auth token, Api key,...
	@ContentType VARCHAR(255)		= 'application/json'--'application/xml'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vWin INT --token of WinHttp object
	DECLARE @vReturnCode INT
	DECLARE @tResponse TABLE (
		ResponseText NVARCHAR(MAX)
	)

	--Creates an instance of WinHttp.WinHttpRequest
	--Doc: https://docs.microsoft.com/en-us/windows/desktop/winhttp/winhttp-versions
	--Version of 5.0 is no longer supported
	EXEC @vReturnCode = sp_OACreate 'WinHttp.WinHttpRequest.5.1'
								   ,@vWin OUT

	IF (@vReturnCode <> 0)
	BEGIN
		GOTO EXCEPTION
	END

	--Opens an HTTP connection to an HTTP resource.
	--Doc: https://docs.microsoft.com/en-us/windows/desktop/winhttp/iwinhttprequest-open
	EXEC @vReturnCode = sp_OAMethod		@vWin
								   ,	'Open'
								   ,	NULL
								   ,	@Method/*Method*/
								   --,	 /*Url*/
								   ,	'false' /*IsAsync*/
	IF @vReturnCode <> 0
	BEGIN
		GOTO EXCEPTION
	END

	IF @Authorization IS NOT NULL
	BEGIN
		EXEC @vReturnCode = sp_OAMethod @vWin
									   ,'SetRequestHeader'
									   ,NULL
									   ,'Authorization'
									   ,@Authorization
		IF @vReturnCode <> 0
			GOTO EXCEPTION
	END

	IF @ContentType IS NOT NULL
	BEGIN
		EXEC @vReturnCode = sp_OAMethod @vWin
									   ,'SetRequestHeader'
									   ,NULL
									   ,'Content-Type'
									   ,@ContentType
		IF @vReturnCode <> 0
			GOTO EXCEPTION
	END

	--Sends an HTTP request to an HTTP server.
	--Doc: https://docs.microsoft.com/en-us/windows/desktop/winhttp/iwinhttprequest-send
	IF @BodyData IS NOT NULL
	BEGIN
		EXEC @vReturnCode = sp_OAMethod @vWin
									   ,'Send'
									   ,NULL
									   ,@BodyData
		IF @vReturnCode <> 0
			GOTO EXCEPTION
	END
	ELSE
	BEGIN
		EXEC @vReturnCode = sp_OAMethod @vWin
									   ,'Send'
		IF @vReturnCode <> 0
			GOTO EXCEPTION
	END

	IF @vReturnCode <> 0
		GOTO EXCEPTION

	--Get Response text
	--Doc: https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-oagetproperty-transact-sql
	INSERT INTO @tResponse (ResponseText)
	EXEC @vReturnCode = sp_OAGetProperty @vWin
										,'ResponseText'
	IF @vReturnCode <> 0
		GOTO EXCEPTION

	IF @vReturnCode = 0
		GOTO RESULT

EXCEPTION:
	BEGIN
		DECLARE @tException TABLE (
			Error BINARY(4)
		   ,Source VARCHAR(8000)
		   ,Description VARCHAR(8000)
		   ,HelpFile VARCHAR(8000)
		   ,HelpID VARCHAR(8000)
		)

		INSERT INTO @tException EXEC sp_OAGetErrorInfo @vWin
		INSERT INTO @tResponse (ResponseText)
			SELECT
				(SELECT
						*
					FROM @tException
					FOR JSON AUTO)
				AS ResponseText
	END

--FINALLY
RESULT:
	--Dispose objects 
	IF @vWin IS NOT NULL
		EXEC sp_OADestroy @vWin

	--Result
	SELECT
		*
	FROM @tResponse

	RETURN
END

GO
