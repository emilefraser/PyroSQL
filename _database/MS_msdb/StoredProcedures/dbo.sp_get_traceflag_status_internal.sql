SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_get_traceflag_status_internal
   @traceflag INT,
   @status INT OUTPUT
AS
BEGIN
    SET @status = NULL

    IF(@traceflag IS NOT NULL)
    BEGIN
        DECLARE @traceStatus TABLE
        (
            TraceFlag int,
            [Status] int,
            [Global] int,
            [Session] int
        )
        INSERT INTO @traceStatus
        EXEC ('DBCC TRACESTATUS (-1) WITH NO_INFOMSGS')

        SELECT @status = [Status]
        FROM @traceStatus
        WHERE TraceFlag = @traceflag
    END
END

GO
