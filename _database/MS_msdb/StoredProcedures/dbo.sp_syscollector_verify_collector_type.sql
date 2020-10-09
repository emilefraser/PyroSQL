SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_verify_collector_type]
    @collector_type_uid        uniqueidentifier = NULL OUTPUT,
    @name                    sysname = NULL OUTPUT
AS
BEGIN
    IF (@name IS NOT NULL)
    BEGIN
        -- Remove any leading/trailing spaces from parameters
        SET @name                    = NULLIF(LTRIM(RTRIM(@name)), N'')
    END

    IF (@collector_type_uid IS NULL AND @name IS NULL)
    BEGIN
        RAISERROR(14624, -1, -1, '@collector_type_uid, @name')
        RETURN(1)
    END

    IF (@collector_type_uid IS NOT NULL AND @name IS NOT NULL)
    BEGIN
        IF (NOT EXISTS(SELECT *
                        FROM dbo.syscollector_collector_types
                        WHERE collector_type_uid = @collector_type_uid
                        AND name = @name))
        BEGIN
            DECLARE @errMsg NVARCHAR(196)
            SELECT @errMsg = CONVERT(NVARCHAR(36), @collector_type_uid) + ', ' + @name
            RAISERROR(14262, -1, -1, '@collector_type_uid, @name', @errMsg)
            RETURN(1)
        END
    END
    -- Check id
    ELSE IF (@collector_type_uid IS NOT NULL)
    BEGIN
        SELECT @name = name
        FROM dbo.syscollector_collector_types
        WHERE (collector_type_uid = @collector_type_uid)
    
        -- the view would take care of all the permissions issues.
        IF (@name IS NULL) 
        BEGIN
            DECLARE @collector_type_uid_as_char VARCHAR(36)
            SELECT @collector_type_uid_as_char = CONVERT(VARCHAR(36), @collector_type_uid)
            RAISERROR(14262, -1, -1, '@collector_type_uid', @collector_type_uid_as_char)
            RETURN(1) -- Failure
        END
    END
    -- Check name
    ELSE IF (@name IS NOT NULL)
    BEGIN
        -- get the corresponding collector_type_uid (if the collector type exists)
        SELECT @collector_type_uid = collector_type_uid
        FROM dbo.syscollector_collector_types
        WHERE (name = @name)

        -- the view would take care of all the permissions issues.
        IF (@collector_type_uid IS NULL)
        BEGIN
            RAISERROR(14262, -1, -1, '@name', @name)
            RETURN(1) -- Failure
        END
    END
    RETURN (0)
END

GO
