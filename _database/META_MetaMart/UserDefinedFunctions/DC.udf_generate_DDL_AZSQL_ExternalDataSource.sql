SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_ExternalDataSource](
	@Type AS VARCHAR(250) = 'RDBMS'
,	@TargetDatabaseID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @Location AS VARCHAR(250)
	DECLARE @DatabaseName AS VARCHAR(250)
	DECLARE @Credential AS VARCHAR(250)
	DECLARE @ExternalSourceName AS VARCHAR(250) 
	DECLARE @ServerID AS INT
	DECLARE @DatabaseInstanceID AS INT

    SET @DatabaseInstanceID = (SELECT DISTINCT DatabaseInstanceID FROM DC.vw_rpt_DatabaseFieldDetailDMOD WHERE DatabaseID = @TargetDatabaseID)
	SELECT @ServerID = ServerID FROM DatabaseInstance WHERE DatabaseInstanceID = @DatabaseInstanceID

	SELECT @Location = [ServerName]  FROM [DC].[Server] WHERE ServerID = @ServerID
	SELECT @DatabaseName = [DatabaseName] FROM [DC].[Database] WHERE DatabaseID = @TargetDatabaseID
	SELECT @Credential = 'dsc_' + [DatabaseName] FROM [DC].[Database] WHERE DatabaseID = @TargetDatabaseID
	SELECT @ExternalSourceName = 'ExtDsrc_' + [DatabaseName] FROM [DC].[Database] WHERE DatabaseID = @TargetDatabaseID

    -- Declare the return variable here
    DECLARE @CreateExternalDataSource AS VARCHAR(MAX)

    SELECT @CreateExternalDataSource = 
	'IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE [name] = ''' + @ExternalSourceName + ''')
		CREATE EXTERNAL DATA SOURCE ' + @ExternalSourceName + '
		WITH
		(
			TYPE = ' + @Type + ',
			LOCATION = ''' + @Location + ''',
			DATABASE_NAME = ''' + @DatabaseName + ''',
			CREDENTIAL = ' + @Credential + '
		);'  + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @CreateExternalDataSource
END

GO
