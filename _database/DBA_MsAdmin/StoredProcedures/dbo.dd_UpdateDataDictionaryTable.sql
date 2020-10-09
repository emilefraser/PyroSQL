SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[dd_UpdateDataDictionaryTable]
    @SchemaName sysname = N'dbo',
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
    UPDATE  dbo.DataDictionary_Tables
    SET     TableDescription = ISNULL(@TableDescription, '')
    WHERE   SchemaName = @SchemaName
            AND TableName = @TableName
    RETURN @@ROWCOUNT

GO
