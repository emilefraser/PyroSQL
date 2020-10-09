SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_collector_type]
    @collector_type_uid            uniqueidentifier = NULL,
    @name                        sysname = NULL
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_delete_collector_type
    ELSE
        BEGIN TRANSACTION
    BEGIN TRY

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END
    
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collector_type @collector_type_uid OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    IF (EXISTS(SELECT * from dbo.syscollector_collection_items
        WHERE @collector_type_uid = collector_type_uid))
    BEGIN
        RAISERROR(14673, -1, -1, @name)
        RETURN (1)
    END
    
    DECLARE @schema_collection sysname
        -- @sql_string should have enough buffer to include 2n+2 max size for QUOTENAME(@schema_collection).
    DECLARE @sql_string nvarchar(285)
    SET @schema_collection = (SELECT schema_collection 
                                FROM syscollector_collector_types_internal
                                WHERE @collector_type_uid = collector_type_uid)
    SET @sql_string = N'DROP XML SCHEMA COLLECTION ' + QUOTENAME(@schema_collection, '[');
    EXEC sp_executesql @sql_string

    DELETE [dbo].[syscollector_collector_types_internal]
    WHERE collector_type_uid = @collector_type_uid

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_delete_collector_type

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
