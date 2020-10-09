SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_DatabaseScopedCredential_Drop](
	@TargetDatabaseID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
	DECLARE @DscDatabaseName AS VARCHAR(MAX)
	DECLARE @DropDatabaseScopedCredential AS VARCHAR(MAX)

	SELECT @DscDatabaseName = 'dsc_' + DatabaseName FROM [DC].[Database] WHERE [DatabaseID] = @TargetDatabaseID

	SELECT @DropDatabaseScopedCredential = '
	IF EXISTS (SELECT * FROM sys.database_credentials WHERE [name] = ''' + @DscDatabaseName + ''')
			DROP DATABASE SCOPED CREDENTIAL ' + @DscDatabaseName + ';' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @DropDatabaseScopedCredential
END

GO
