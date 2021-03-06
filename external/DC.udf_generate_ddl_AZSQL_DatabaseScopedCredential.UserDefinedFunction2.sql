USE [DataManager]
GO
/****** Object:  UserDefinedFunction [DC].[udf_generate_ddl_AZSQL_DatabaseScopedCredential]    Script Date: 6/15/2020 01:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[GenerateDatabaseScopedCredential](
	@TargetDatabaseName
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
	DECLARE @DatabaseScopedCredentialReturn AS VARCHAR(MAX)

	SELECT @DscDatabaseName = 'dsc_' + DatabaseName FROM [DC].[Database] WHERE [DatabaseID] = @TargetDatabaseID
	SELECT @DatabaseInstanceID = DatabaseInstanceID FROM [DC].[Database] WHERE [DatabaseID] = @TargetDatabaseID
	SELECT @ScopedCredential = AuthUserName FROM [DC].[DatabaseInstance] WHERE [DatabaseInstanceID] = @DatabaseInstanceID
	SELECT @ScopedSecret = AuthPassword FROM [DC].[DatabaseInstance] WHERE [DatabaseInstanceID] = @DatabaseInstanceID

	SELECT @DatabaseScopedCredentialReturn = '
	IF NOT EXISTS (SELECT * FROM sys.database_credentials WHERE [name] = ''' + @DscDatabaseName + ''')
			CREATE DATABASE SCOPED CREDENTIAL ' + @DscDatabaseName 
	+ '		WITH IDENTITY = ''' + @ScopedCredential + '''
	   ,	SECRET = ''' + @ScopedSecret + ''';' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @DatabaseScopedCredentialReturn
END
GO
