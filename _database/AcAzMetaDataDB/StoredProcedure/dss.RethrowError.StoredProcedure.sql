SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[RethrowError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[RethrowError] AS' 
END
GO
ALTER PROCEDURE [dss].[RethrowError]
AS
BEGIN
    DECLARE
        @ErrorMessage    NVARCHAR(4000),
        @ErrorNumber     INT,
        @ErrorSeverity   INT,
        @ErrorState      INT,
        @ErrorLine       INT,
        @ErrorProcedure  NVARCHAR(200);

    SELECT
        @ErrorNumber = ERROR_NUMBER()

    -- Return if there is no error information to retrieve.
    IF @ErrorNumber IS NULL
        RETURN;


    -- Assign variables to error-handling functions that
    -- capture information for RAISERROR.
    SELECT
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorLine = ERROR_LINE(),
        @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

    IF (@ErrorNumber >= 13000 AND @ErrorNumber <> 50000)
    BEGIN
        -- Assign variables to error-handling functions that
        -- capture information for RAISERROR.
        SELECT
             @ErrorSeverity = @ErrorSeverity
            ,@ErrorState = @ErrorState
            ,@ErrorMessage = @ErrorMessage

        RAISERROR
            (
            @ErrorNumber,
            @ErrorSeverity,
            @ErrorState,
            @ErrorMessage
            );
    END
    ELSE
    BEGIN
        -- Build the message string that will contain original
        -- error information.
        SELECT @ErrorMessage =
            N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
                'Message: '+ ERROR_MESSAGE();

        -- Raise an error: msg_str parameter of RAISERROR will contain
        -- the original error information.
        RAISERROR
            (
            @ErrorMessage,
            @ErrorSeverity,
            1,
            @ErrorNumber,    -- parameter: original error number.
            @ErrorSeverity,  -- parameter: original error severity.
            @ErrorState,     -- parameter: original error state.
            @ErrorProcedure, -- parameter: original error procedure name.
            @ErrorLine       -- parameter: original error line number.
            );
    END
END
GO
