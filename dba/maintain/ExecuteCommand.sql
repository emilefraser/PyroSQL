USE MsAdmin;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET NOCOUNT ON;
GO

-- Check id the schema exists
IF NOT EXISTS (
	SELECT 
		1
    FROM 
		sys.schemas
    WHERE 
		name = N'dba'
)
BEGIN
	EXEC ('CREATE SCHEMA dba');
END;

-- Check if the proc exists 
IF NOT EXISTS (
    SELECT 
		1
    FROM 
		sys.objects
    WHERE object_id = OBJECT_ID(N'[dba].[ExecuteCommand]')
          AND type IN(N'P', N'PC')
)
    BEGIN
        EXEC dbo.sp_executesql 
             @statement = N'CREATE PROCEDURE [dbs].[ExecuteCommand] AS';
END;
GO


CREATE PROCEDURE [dba].[ExecuteCommand] 
							@Command					NVARCHAR(MAX), 
                            @CommandType				NVARCHAR(MAX), 
                            @Mode						INT, 
                            @Comment					NVARCHAR(MAX)	= NULL, 
							@ServerName					NVARCHAR(MAX)	= NULL,
							@DatabaseInstanceName		NVARCHAR(MAX)	= NULL,
                            @DatabaseName				NVARCHAR(MAX)	= NULL, 
                            @SchemaName					NVARCHAR(MAX)	= NULL, 
                            @ObjectName					NVARCHAR(MAX)	= NULL, 
                            @ObjectType					NVARCHAR(MAX)	= NULL, 
                            @IndexName					NVARCHAR(MAX)	= NULL, 
                            @IndexType					INT				= NULL, 
                            @StatisticsName				NVARCHAR(MAX)	= NULL, 
                            @PartitionNumber			INT				= NULL, 
                            @ExtendedInfo				XML				= NULL, 
                            @sql_log					BIT				= 1 ,
							@sql_debug					BIT				= 0 ,
                            @sql_execute				BIT				= 0
AS
    BEGIN

       
        DECLARE @StartMessage NVARCHAR(MAX);
        DECLARE @EndMessage NVARCHAR(MAX);
        DECLARE @ErrorMessage NVARCHAR(MAX);
        DECLARE @ErrorMessageOriginal NVARCHAR(MAX);
        DECLARE @StartTime DATETIME2(7);
        DECLARE @EndTime DATETIME2(7);
        DECLARE @StartTimeSec DATETIME2(7);
        DECLARE @EndTimeSec DATETIME2(7);
        DECLARE @ID INT;
        DECLARE @Error INT;
        DECLARE @ReturnCode INT;
		DECLARE @sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @RC INT 

        SET @Error = 0;
        SET @ReturnCode = 0;

        ----------------------------------------------------------------------------------------------------
        --// Check core requirements                                                                    //--
        ----------------------------------------------------------------------------------------------------
        IF (@sql_log = 1)
				   AND NOT EXISTS (
					SELECT 1
					FROM sys.objects objects
						 INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id]
					WHERE objects.[type] = 'U'
						  AND schemas.[name] = 'dbo'
						  AND objects.[name] = 'CommandLog'
				)
            BEGIN
                SET @ErrorMessage = 'The table dba.CommandLog is missing. Creating it...' + @sql_crlf + ' ';
				EXEC @RC = dba.CreateCommandLog

				IF(@RC != 0)
				BEGIN
					RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
					SET @Error = @@ERROR;
				END;
        END;
        IF @Error <> 0
            BEGIN
                SET @ReturnCode = @Error;
                GOTO ReturnCode;
        END;

        ----------------------------------------------------------------------------------------------------
        --// Check input parameters                                                                     //--
        ----------------------------------------------------------------------------------------------------
        IF @Command IS NULL
           OR @Command = ''
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @Command is not supported.' + @sql_crlf + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;
		
		IF @CommandType IS NULL
           OR @CommandType = ''
           OR LEN(@CommandType) > 60
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @CommandType is not supported.' + + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;

        IF @Mode NOT IN(1, 2)
           OR @Mode IS NULL
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @Mode is not supported.' + @sql_crlf + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;

        IF @sql_log NOT IN(1, 0)
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @sql_log is not supported.' + @sql_crlf + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;

        IF @sql_execute NOT IN(1, 0)
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @sql_execute is not supported.' + @sql_crlf + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;

		IF @sql_debug NOT IN(1, 0)
            BEGIN
                SET @ErrorMessage = 'The value for the parameter @sql_debug is not supported.' + @sql_crlf + ' ';
                RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
                SET @Error = @@ERROR;
        END;

        IF @Error <> 0
            BEGIN
                SET @ReturnCode = @Error;
                GOTO ReturnCode;
        END;

        ----------------------------------------------------------------------------------------------------
        --// Log initial information                                                                    //--
        ----------------------------------------------------------------------------------------------------
        SET @StartTime = GETDATE();
        SET @StartTimeSec = CONVERT(DATETIME, CONVERT(NVARCHAR, @StartTime, 120), 120);
        SET @StartMessage = 'Date and time: ' + CONVERT(NVARCHAR, @StartTimeSec, 120);
        RAISERROR(@StartMessage, 10, 1) WITH NOWAIT;
        
		SET @StartMessage = 'Command: ' + @Command;
        SET @StartMessage = REPLACE(@StartMessage, '%', '%%');
        RAISERROR(@StartMessage, 10, 1) WITH NOWAIT;

        IF @Comment IS NOT NULL
            BEGIN
                SET @StartMessage = 'Comment: ' + @Comment;
                SET @StartMessage = REPLACE(@StartMessage, '%', '%%');
                RAISERROR(@StartMessage, 10, 1) WITH NOWAIT;
        END;

        IF @sql_log = 1
            BEGIN
                INSERT INTO dba.CommandLog (
					DatabaseName, 
					 SchemaName, 
					 ObjectName, 
					 ObjectType, 
					 IndexName, 
					 IndexType, 
					 StatisticsName, 
					 PartitionNumber, 
					 ExtendedInfo, 
					 CommandType, 
					 Command, 
					 StartTime
                )
                VALUES (
					 @DatabaseName, 
					 @SchemaName, 
					 @ObjectName, 
					 @ObjectType, 
					 @IndexName, 
					 @IndexType, 
					 @StatisticsName, 
					 @PartitionNumber, 
					 @ExtendedInfo, 
					 @CommandType, 
					 @Command, 
					 @StartTime
                );
        END;
        
		SET @ID = SCOPE_IDENTITY();

        ----------------------------------------------------------------------------------------------------
        --// Execute command                                                                            //--
        ----------------------------------------------------------------------------------------------------
        IF @Mode = 1
           AND @sql_execute = 1
            BEGIN
                EXECUTE (@Command);
                SET @Error = @@ERROR;
                SET @ReturnCode = @Error;
        END;
        IF @Mode = 2
           AND @sql_execute = 1
            BEGIN
                BEGIN TRY
                    EXECUTE (@Command);
        END TRY
                BEGIN CATCH
                    SET @Error = ERROR_NUMBER();
                    SET @ReturnCode = @Error;
                    SET @ErrorMessageOriginal = ERROR_MESSAGE();
                    SET @ErrorMessage = 'Msg ' + CAST(@Error AS NVARCHAR) + ', ' + ISNULL(@ErrorMessageOriginal, '');
                    RAISERROR(@ErrorMessage, 16, 1) WITH NOWAIT;
        END CATCH;
        END;

        ----------------------------------------------------------------------------------------------------
        --// Log completing information                                                                 //--
        ----------------------------------------------------------------------------------------------------
        SET @EndTime = GETDATE();
        SET @EndTimeSec = CONVERT(DATETIME, CONVERT(VARCHAR, @EndTime, 120), 120);
        SET @EndMessage = 'Outcome: ' + CASE
                                            WHEN @sql_execute = 0
                                            THEN 'Not Executed'
                                            WHEN @Error = 0
                                            THEN 'Succeeded'
                                            ELSE 'Failed'
                                        END;
        RAISERROR(@EndMessage, 10, 1) WITH NOWAIT;
        
		SET @EndMessage = 'Duration: ' + CASE
                                             WHEN DATEDIFF(ss, @StartTimeSec, @EndTimeSec) / (24 * 3600) > 0
                                             THEN CAST(DATEDIFF(ss, @StartTimeSec, @EndTimeSec) / (24 * 3600) AS NVARCHAR) + '.'
                                             ELSE ''
                                         END + CONVERT(NVARCHAR, @EndTimeSec - @StartTimeSec, 108);
        RAISERROR(@EndMessage, 10, 1) WITH NOWAIT;
        
		SET @EndMessage = 'Date and time: ' + CONVERT(NVARCHAR, @EndTimeSec, 120) + CHAR(13) + CHAR(10) + ' ';
        RAISERROR(@EndMessage, 10, 1) WITH NOWAIT;
       
	   IF @sql_log = 1
            BEGIN
                UPDATE dba.CommandLog
                  SET 
                      EndTime = @EndTime, 
                      ErrorNumber = CASE
                                        WHEN @sql_execute = 0
                                        THEN NULL
                                        ELSE @Error
                                    END, 
                      ErrorMessage = @ErrorMessageOriginal
                WHERE ID = @ID;
        END;



        ReturnCode:
        IF @ReturnCode <> 0
            BEGIN
                RETURN @ReturnCode;
        END;

        ----------------------------------------------------------------------------------------------------

    END;
GO