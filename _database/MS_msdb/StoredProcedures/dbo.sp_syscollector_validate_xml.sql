SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_validate_xml]
    @collector_type_uid        uniqueidentifier = NULL,
    @name                    sysname = NULL,
    @parameters                xml
AS
BEGIN
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collector_type @collector_type_uid OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    DECLARE @schema_collection sysname
    SET @schema_collection = (SELECT schema_collection 
                                FROM syscollector_collector_types_internal
                                WHERE @collector_type_uid = collector_type_uid)

    IF (@schema_collection IS NULL)
    BEGIN
        RAISERROR(21263, -1, -1, '@schema_collection')
        RETURN (1)
    END

        -- @sql_string should have enough buffer to include 2n+2 max size for QUOTENAME(@schema_collection).
    DECLARE @sql_string nvarchar(328)
    DECLARE @param_definition nvarchar(16)
    SET @param_definition = N'@param xml'
    SET @sql_string = N'DECLARE @validated_xml XML (DOCUMENT ' + QUOTENAME(@schema_collection, '[') + N'); SELECT @validated_xml = @param';
    EXEC @retVal = sp_executesql @sql_string, @param_definition, @param = @parameters

    IF (@retVal <> 0)
    BEGIN
        RETURN (1)
    END
END

GO
