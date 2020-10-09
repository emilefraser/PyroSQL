SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_upload_instmdw]
    @installpath              nvarchar(2048) = NULL
AS
BEGIN
    -- only dc_admin and dbo can setup MDW
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14712, -1, -1) WITH LOG
        RETURN(1) -- Failure
    END

    IF (@installpath IS NULL)
    BEGIN
        EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @installpath OUTPUT;
    
        IF RIGHT(@installpath, 1) != N'\' set @installpath = @installpath + N'\'
        SET @installpath  = @installpath + N'Install\'
    END

    DECLARE @filename nvarchar(2048);
    SET @filename = @installpath + N'instmdw.sql'
    PRINT 'Uploading instmdw.sql from disk: ' + @filename

    CREATE TABLE #bulkuploadinstmdwscript
        (
            [instmdwscript] nvarchar(max) NOT NULL
        );


    DECLARE @stmt_bulkinsert nvarchar(2048);
    SET @stmt_bulkinsert = N'
    BULK INSERT #bulkuploadinstmdwscript
    FROM ' 
        -- Escape any embedded single quotes (we can't use QUOTENAME here b/c it can't handle strings > 128 chars)
        + '''' + REPLACE(@filename COLLATE database_default, N'''', N'''''') + '''
    WITH
        (
            DATAFILETYPE = ''char'',
            FIELDTERMINATOR = ''dc:stub:ft'',
            ROWTERMINATOR = ''dc:stub:rt''
        );
    ';

    EXECUTE sp_executesql @stmt_bulkinsert;

    DECLARE @bytesLoaded int
    SELECT @bytesLoaded = ISNULL (DATALENGTH ([instmdwscript]), 0) FROM #bulkuploadinstmdwscript
    PRINT 'Loaded ' + CONVERT (nvarchar, @bytesLoaded)
            + ' bytes from ' + '''' + REPLACE(@filename COLLATE database_default, N'''', N'''''') + ''''

    DECLARE @scriptdata varbinary(max)
    SELECT @scriptdata = convert(varbinary(max), [instmdwscript]) FROM #bulkuploadinstmdwscript;

    IF (EXISTS(SELECT * FROM [dbo].[syscollector_blobs_internal]
        WHERE parameter_name = N'InstMDWScript'))
    BEGIN
        UPDATE [dbo].[syscollector_blobs_internal]
        SET parameter_value = @scriptdata
        WHERE parameter_name = N'InstMDWScript'
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[syscollector_blobs_internal] (
            parameter_name, 
            parameter_value
        )
        VALUES
        (
            N'InstMDWScript',
            @scriptdata
        )
    END

    DROP TABLE #bulkuploadinstmdwscript
END

GO
