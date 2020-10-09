SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_create_collection_item]
    @collection_set_id        int,
    @collector_type_uid        uniqueidentifier,
    @name                    sysname,
    @frequency                int = 5,                -- set by default to the minimum frequency
    @parameters                xml = NULL,
    @collection_item_id        int OUTPUT
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_create_collection_item
    ELSE
        BEGIN TRANSACTION
    BEGIN TRY
        -- Security check (role membership)
        IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        BEGIN
            RAISERROR(14677, -1, -1, 'dc_admin')
            RETURN (1)
        END

        DECLARE @is_system bit
        SELECT    @is_system = is_system
        FROM dbo.syscollector_collection_sets
        WHERE collection_set_id = @collection_set_id
        
        IF (@is_system = 1)
        BEGIN
            -- cannot update, delete, or add new collection items to a system collection set
            RAISERROR(14696, -1, -1);
            RETURN (1)
        END

        SET @name            = NULLIF(LTRIM(RTRIM(@name)), N'')
        IF (@name IS NULL) 
        BEGIN
            RAISERROR(21263, -1, -1, '@name')
            RETURN (1)
        END
        
        IF (@frequency < 5)
        BEGIN
            DECLARE @frequency_as_char VARCHAR(36)
            SELECT @frequency_as_char = CONVERT(VARCHAR(36), @frequency)
            RAISERROR(21405, 16, -1, @frequency_as_char, '@frequency', 5)
            RETURN (1)
        END

        IF (NOT EXISTS(SELECT * from dbo.syscollector_collector_types
            WHERE @collector_type_uid = collector_type_uid))
        BEGIN
            DECLARE @collector_type_uid_as_char VARCHAR(36)
            SELECT @collector_type_uid_as_char = CONVERT(VARCHAR(36), @collector_type_uid)
            RAISERROR(14262, -1, -1, '@collector_type_uid', @collector_type_uid_as_char)
            RETURN (1)
        END
        
        IF (NOT EXISTS(SELECT * from dbo.syscollector_collection_sets
            WHERE @collection_set_id = collection_set_id))
        BEGIN
            DECLARE @collection_set_id_as_char VARCHAR(36)
            SELECT @collection_set_id_as_char = CONVERT(VARCHAR(36), @collection_set_id)
            RAISERROR(14262, -1, -1, '@collection_set_id', @collection_set_id_as_char)
            RETURN (1)
        END

        DECLARE @is_running bit
        SELECT    @is_running = is_running
        FROM dbo.syscollector_collection_sets
        WHERE collection_set_id = @collection_set_id
        IF (@is_running = 1)
        BEGIN
            RAISERROR(14675, -1, -1, @name)
            RETURN (1)
        END

        IF (@parameters IS NULL)
        BEGIN
            DECLARE @parameter_schema xml
            SELECT @parameter_schema = parameter_schema FROM syscollector_collector_types WHERE collector_type_uid = @collector_type_uid
            IF (@parameter_schema IS NOT NULL)    -- only allows parameters to be null if the collector type has a null schema
            BEGIN
                RAISERROR(21263, -1, -1, '@parameters')
                RETURN (1)
            END
        END
        ELSE IF (LTRIM(RTRIM(CONVERT(nvarchar(max), @parameters))) <> N'') -- don't check if the parameters are empty string
        BEGIN
            EXEC dbo.sp_syscollector_validate_xml @collector_type_uid = @collector_type_uid, @parameters = @parameters
        END

        INSERT INTO [dbo].[syscollector_collection_items_internal]
        (
            collection_set_id,
            collector_type_uid,
            name,
            frequency,
            parameters
        )
        VALUES
        (
            @collection_set_id,
            @collector_type_uid,
            @name,
            @frequency,
            @parameters
        )

        SET @collection_item_id = SCOPE_IDENTITY()

        IF (@collection_item_id IS NULL)
        BEGIN
            DECLARE @collection_item_id_as_char VARCHAR(36)
            SELECT @collection_item_id_as_char = CONVERT(VARCHAR(36), @collection_item_id)
            RAISERROR(14262, -1, -1, '@collection_item_id', @collection_item_id_as_char)
            RETURN (1)
        END

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_create_collection_item

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
