SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_verify_event_log_id]
    @log_id bigint,
    @allow_collection_set_id bit = 0
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @log_id_as_char VARCHAR(36)

    IF (@log_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@log_id')
        RETURN (1)
    END
    ELSE IF @allow_collection_set_id = 0
    BEGIN
        IF (NOT EXISTS (SELECT log_id FROM dbo.syscollector_execution_log WHERE log_id = @log_id AND package_id IS NOT NULL))
        BEGIN
            SELECT @log_id_as_char = CONVERT(VARCHAR(36), @log_id)

            RAISERROR(14262, -1, -1, '@log_id', @log_id_as_char)
            RETURN (1)
        END
    END
    ELSE
    BEGIN
        IF (NOT EXISTS (SELECT log_id FROM dbo.syscollector_execution_log WHERE log_id = @log_id))
        BEGIN
            SELECT @log_id_as_char = CONVERT(VARCHAR(36), @log_id)

            RAISERROR(14262, -1, -1, '@log_id', @log_id_as_char)
            RETURN (1)
        END
    END

    RETURN (0)
END

GO
