SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_get_warehouse_connection_string]
    @connection_string              nvarchar(512) = NULL OUTPUT
AS
BEGIN
    DECLARE @instance_name sysname
    DECLARE @database_name sysname
    DECLARE @user_name sysname
    DECLARE @password sysname
    DECLARE @product_version  nvarchar(128) -- SERVERPROPERTY('ProductVersion') returns value of type nvarchar(128)
    DECLARE @provider_name  nvarchar(128)

    SELECT @instance_name = CONVERT(sysname,parameter_value)
    FROM [msdb].[dbo].[syscollector_config_store_internal]
    WHERE parameter_name = N'MDWInstance'

    IF (@instance_name IS NULL)
    BEGIN
        RAISERROR(14686, -1, -1)
        RETURN (1)
    END
    
    -- '"' is the delimiter for the sql client connection string
    SET @instance_name = QUOTENAME(@instance_name, '"')

    SELECT @database_name = CONVERT(sysname,parameter_value)
    FROM [msdb].[dbo].[syscollector_config_store_internal]
    WHERE parameter_name = N'MDWDatabase'

    IF (@database_name IS NULL)
    BEGIN
        RAISERROR(14686, -1, -1)
        RETURN (1)
    END

    SET @database_name = QUOTENAME(@database_name, '"')
    
    SET @product_version = CONVERT(nvarchar(128), SERVERPROPERTY('ProductVersion'))
	
    -- SQLNCLI11 remains as SQLNCLI11 for SQL12 
    SET @provider_name = 'SQLNCLI11'
    SET @connection_string = N'Data Source=' + @instance_name + N';Application Name="Data Collector - MDW";Initial Catalog=' + @database_name
    SET @connection_string = @connection_string + N';Use Encryption for Data=true;Trust Server Certificate=true;Provider=' + @provider_name 
    SET @connection_string = @connection_string + N';Integrated Security=SSPI;Connect Timeout=60;';

    RETURN (0)
END

GO
