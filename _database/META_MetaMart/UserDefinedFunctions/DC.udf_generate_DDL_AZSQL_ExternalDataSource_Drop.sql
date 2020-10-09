SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_ExternalDataSource_Drop](
	@Type AS VARCHAR(250) = 'RDBMS'
,	@TargetDatabaseID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @ExternalSourceName AS VARCHAR(250) 

	SELECT @ExternalSourceName = 'ExtDsrc_' + [DatabaseName] FROM [DC].[Database] WHERE DatabaseID = @TargetDatabaseID

    -- Declare the return variable here
    DECLARE @DropExternalDataSource AS VARCHAR(MAX)

    SELECT @DropExternalDataSource = 
	'IF EXISTS (SELECT * FROM sys.external_data_sources WHERE [name] = ''' + @ExternalSourceName + ''')
		DROP EXTERNAL DATA SOURCE ' + @ExternalSourceName +';'  + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @DropExternalDataSource
END

GO
