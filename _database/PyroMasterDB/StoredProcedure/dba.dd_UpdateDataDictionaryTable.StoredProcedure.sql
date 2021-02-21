SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dd_UpdateDataDictionaryTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dd_UpdateDataDictionaryTable] AS' 
END
GO

ALTER PROC [dba].[dd_UpdateDataDictionaryTable]
    @SchemaName sysname = N'dba',
    @TableName sysname, 
    @TableDescription VARCHAR(7000) = '' 
AS

/**************************************************************************************************************
**  Purpose: USE THIS TO MANUALLY UPDATE AN INDIVIDUAL TABLE/FIELD, THEN RUN POPULATE SCRIPT AGAIN
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/

    SET NOCOUNT ON
    UPDATE  dba.DataDictionary_Tables
    SET     TableDescription = ISNULL(@TableDescription, '')
    WHERE   SchemaName = @SchemaName
            AND TableName = @TableName
    RETURN @@ROWCOUNT
GO
