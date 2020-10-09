SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_create_collector_type]
    @collector_type_uid            uniqueidentifier = NULL OUTPUT,
    @name                        sysname,
    @parameter_schema            xml = NULL,
    @parameter_formatter        xml = NULL,
    @collection_package_id        uniqueidentifier,
    @upload_package_id            uniqueidentifier
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_create_collector_type
    ELSE
        BEGIN TRANSACTION
    BEGIN TRY

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END

    SET @name                = NULLIF(LTRIM(RTRIM(@name)), N'')
    IF (@name IS NULL) 
    BEGIN
        RAISERROR(21263, -1, -1, '@name', @name)
        RETURN (1)
    END

    IF (@collector_type_uid IS NULL) 
    BEGIN
        SET @collector_type_uid = NEWID()
    END
    
    IF (NOT EXISTS(SELECT * from sysssispackages
        WHERE @collection_package_id = id))
    BEGIN
        DECLARE @collection_package_id_as_char VARCHAR(36)
        SELECT @collection_package_id_as_char = CONVERT(VARCHAR(36), @collection_package_id)
        RAISERROR(14262, -1, -1, '@collection_package_id', @collection_package_id_as_char)
        RETURN (1)
    END

    IF (NOT EXISTS(SELECT * from sysssispackages
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
    IF (@parameter_schema IS NOT NULL)
    BEGIN
        SET @schema_collection = N'schema_collection_' + @name
        WHILE (EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = @schema_collection))
        BEGIN
            SET @schema_collection = LEFT(@schema_collection, 119) + '_' + RIGHT(STR(FLOOR(RAND() * 100000000)),8)
        END

        DECLARE @retVal int
        DECLARE @sql_string nvarchar(2048)
        DECLARE @param_definition nvarchar(16)
        SET @param_definition = N'@schema xml'
        SET @sql_string = N'CREATE XML SCHEMA COLLECTION ' + QUOTENAME(@schema_collection, '[') + N' AS @schema; '
        SET @sql_string = @sql_string + N'GRANT EXECUTE ON XML SCHEMA COLLECTION::[dbo].' + QUOTENAME(@schema_collection, '[') + N' TO dc_admin; ' 
        SET @sql_string = @sql_string + N'GRANT VIEW DEFINITION ON XML SCHEMA COLLECTION::[dbo].' + QUOTENAME(@schema_collection, '[') + N' TO dc_admin; '

        EXEC sp_executesql @sql_string, @param_definition, @schema = @parameter_schema
    END

    INSERT INTO [dbo].[syscollector_collector_types_internal]
    (
        collector_type_uid,
        name,
        parameter_schema,
        parameter_formatter,
        schema_collection,
        collection_package_name,
        collection_package_folderid,
        upload_package_name,
        upload_package_folderid
    )
    VALUES
    (
        @collector_type_uid,
        @name,
        @parameter_schema,
        @parameter_formatter,
        @schema_collection,
        @collection_package_name,
        @collection_package_folderid,
        @upload_package_name,
        @upload_package_folderid
    )

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_create_collector_type

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
