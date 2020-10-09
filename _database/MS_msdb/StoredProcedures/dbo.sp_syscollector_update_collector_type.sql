SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_update_collector_type]
    @collector_type_uid            uniqueidentifier = NULL,
    @name                        sysname = NULL,
    @parameter_schema            xml = NULL,
    @parameter_formatter        xml = NULL,
    @collection_package_id        uniqueidentifier,
    @upload_package_id            uniqueidentifier
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_update_collector_type
    ELSE
        BEGIN TRANSACTION
    BEGIN TRY

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END

    -- Check the validity of the name/uid pair
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collector_type @collector_type_uid OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)
    
    DECLARE @old_parameter_schema       xml
    DECLARE @old_parameter_formatter    xml
    DECLARE @old_collection_package_id  uniqueidentifier
    DECLARE @old_upload_package_id      uniqueidentifier

    SELECT  @old_parameter_schema = parameter_schema,
            @old_parameter_formatter = parameter_formatter,
            @old_collection_package_id = collection_package_id,
            @old_upload_package_id = upload_package_id
    FROM [dbo].[syscollector_collector_types]
    WHERE name = @name
    AND collector_type_uid = @collector_type_uid

    IF (@collection_package_id IS NULL)
    BEGIN
        SET @collection_package_id = @old_collection_package_id
    END
    ELSE IF (NOT EXISTS(SELECT * from sysssispackages
                        WHERE @collection_package_id = id))
    BEGIN
        DECLARE @collection_package_id_as_char VARCHAR(36)
        SELECT @collection_package_id_as_char = CONVERT(VARCHAR(36), @collection_package_id)
        RAISERROR(14262, -1, -1, '@collection_package_id', @collection_package_id_as_char)
        RETURN (1)
    END

    IF (@upload_package_id IS NULL)
    BEGIN
        SET @upload_package_id = @old_upload_package_id
    END
    ELSE IF (NOT EXISTS(SELECT * from sysssispackages
                        WHERE @upload_package_id = id))
    BEGIN
        DECLARE @upload_package_id_as_char VARCHAR(36)
        SELECT @upload_package_id_as_char = CONVERT(VARCHAR(36), @upload_package_id)
        RAISERROR(14262, -1, -1, '@upload_package_id', @upload_package_id_as_char)
        RETURN (1)
    END

    DECLARE @collection_package_name sysname
    DECLARE @collection_package_folderid uniqueidentifier
    DECLARE @upload_package_name sysname
    DECLARE @upload_package_folderid uniqueidentifier    

    SELECT 
        @collection_package_name = name,
        @collection_package_folderid = folderid
    FROM sysssispackages
    WHERE @collection_package_id = id

    SELECT 
        @upload_package_name = name,
        @upload_package_folderid = folderid
    FROM sysssispackages
    WHERE @upload_package_id = id

    DECLARE @schema_collection sysname
    IF (@parameter_schema IS NULL)
    BEGIN
        SET @parameter_schema = @old_parameter_schema
    END
    ELSE
    BEGIN
        SELECT @schema_collection = schema_collection
        FROM [dbo].[syscollector_collector_types_internal]
        WHERE name = @name
        AND collector_type_uid = @collector_type_uid

        -- if a previous xml schema collection existed with the same name, drop it in favor of the new schema
        IF (EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = @schema_collection))
        BEGIN
            DECLARE @sql_drop_schema nvarchar(512)
            SET @sql_drop_schema = N'DROP XML SCHEMA COLLECTION ' + QUOTENAME(@schema_collection)
            EXECUTE sp_executesql @sql_drop_schema
        END

        IF(@schema_collection IS NULL)
        BEGIN
            SELECT @schema_collection = 'schema_collection' + name
            FROM [dbo].[syscollector_collector_types_internal]
            WHERE collector_type_uid = @collector_type_uid
        END

        -- recreate it with the new schema
        DECLARE @sql_create_schema nvarchar(2048)
        DECLARE @param_definition nvarchar(16)
        SET @param_definition = N'@schema xml'
        SET @sql_create_schema = N'CREATE XML SCHEMA COLLECTION ' + QUOTENAME(@schema_collection) + N' AS @schema; '
        SET @sql_create_schema = @sql_create_schema + N'GRANT EXECUTE ON XML SCHEMA COLLECTION::[dbo].' + QUOTENAME(@schema_collection) + N' TO dc_admin; ' 
        SET @sql_create_schema = @sql_create_schema + N'GRANT VIEW DEFINITION ON XML SCHEMA COLLECTION::[dbo].' + QUOTENAME(@schema_collection) + N' TO dc_admin; '
            
        EXEC sp_executesql @sql_create_schema, @param_definition, @schema = @parameter_schema
    END

    UPDATE [dbo].[syscollector_collector_types_internal]
    SET parameter_schema = @parameter_schema,
        parameter_formatter = @parameter_formatter,
        schema_collection = @schema_collection,
        collection_package_name = @collection_package_name,
        collection_package_folderid = @collection_package_folderid,
        upload_package_name = @upload_package_name,
        upload_package_folderid = @upload_package_folderid
    WHERE @collector_type_uid = collector_type_uid
    AND   @name = name

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_update_collector_type

        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        RAISERROR (14684, @ErrorSeverity, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);

        RETURN (1)    
    END CATCH
END

GO
