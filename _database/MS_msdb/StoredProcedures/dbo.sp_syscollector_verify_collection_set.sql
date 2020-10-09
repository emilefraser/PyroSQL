SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_verify_collection_set]
    @collection_set_id        int = NULL OUTPUT,
    @name                    sysname = NULL OUTPUT
AS
BEGIN
    IF (@name IS NOT NULL)
    BEGIN
        -- Remove any leading/trailing spaces from parameters
        SET @name =            NULLIF(LTRIM(RTRIM(@name)), N'')
    END

    IF (@collection_set_id IS NULL AND @name IS NULL)
    BEGIN
        RAISERROR(14624, -1, -1, '@collection_set_id, @name')
        RETURN(1)
    END

    IF (@collection_set_id IS NOT NULL AND @name IS NOT NULL)
    BEGIN
        IF (NOT EXISTS(SELECT *
                        FROM dbo.syscollector_collection_sets
                        WHERE collection_set_id = @collection_set_id
                        AND name = @name))
        BEGIN
            DECLARE @errMsg NVARCHAR(196)
            SELECT @errMsg = CONVERT(NVARCHAR(36), @collection_set_id) + ', ' + @name
            RAISERROR(14262, -1, -1, '@collection_set_id, @name', @errMsg)
            RETURN(1)
        END
    END
    -- Check id
    ELSE IF (@collection_set_id IS NOT NULL)
    BEGIN
        SELECT @name = name
        FROM dbo.syscollector_collection_sets
        WHERE (collection_set_id = @collection_set_id)
    
        -- the view would take care of all the permissions issues.
        IF (@name IS NULL) 
        BEGIN
            DECLARE @collection_set_id_as_char VARCHAR(36)
            SELECT @collection_set_id_as_char = CONVERT(VARCHAR(36), @collection_set_id)
            RAISERROR(14262, -1, -1, '@collection_set_id', @collection_set_id_as_char)
            RETURN(1) -- Failure
        END
    END
    -- Check name
    ELSE IF (@name IS NOT NULL)
    BEGIN
        -- get the corresponding collection_set_id (if the collection set exists)
        SELECT @collection_set_id = collection_set_id
        FROM dbo.syscollector_collection_sets
        WHERE (name = @name)

        -- the view would take care of all the permissions issues.
        IF (@collection_set_id IS NULL)
        BEGIN
            RAISERROR(14262, -1, -1, '@name', @name)
            RETURN(1) -- Failure
        END
    END
    RETURN (0)
END

GO
