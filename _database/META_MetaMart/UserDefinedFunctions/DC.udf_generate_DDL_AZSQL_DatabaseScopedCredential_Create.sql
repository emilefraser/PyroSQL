SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_DatabaseScopedCredential_Create](
	@TargetDatabaseID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
	DECLARE @DscCredentialName AS VARCHAR(MAX)
	DECLARE @DscDatabaseName AS VARCHAR(MAX)
	DECLARE @DatabaseInstanceID AS VARCHAR(MAX)
    DECLARE @ScopedCredential AS VARCHAR(MAX)
	DECLARE @ScopedSecret AS VARCHAR(MAX)
	DECLARE @CreateDatabaseScopedCredential AS VARCHAR(MAX)

	SELECT @DscDatabaseName = 'dsc_' + DatabaseName FROM [DC].[Database] WHERE [DatabaseID] = @TargetDatabaseID
	SELECT @DatabaseInstanceID = DatabaseInstanceID FROM [DC].[Database] WHERE [DatabaseID] = @TargetDatabaseID
	SELECT @ScopedCredential = AuthUserName FROM [DC].[DatabaseInstance] WHERE [DatabaseInstanceID] = @DatabaseInstanceID
	SELECT @ScopedSecret = AuthPassword FROM [DC].[DatabaseInstance] WHERE [DatabaseInstanceID] = @DatabaseInstanceID

	SELECT @CreateDatabaseScopedCredential = '
	IF NOT EXISTS (SELECT * FROM sys.database_credentials WHERE [name] = ''' + @DscDatabaseName + ''')
			CREATE DATABASE SCOPED CREDENTIAL ' + @DscDatabaseName 
	+ '		WITH IDENTITY = ''' + @ScopedCredential + '''
	   ,	SECRET = ''' + @ScopedSecret + ''';' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @CreateDatabaseScopedCredential
END

GO
