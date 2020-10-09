SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_update_utility_configuration] 
   @name SYSNAME,
   @value SQL_VARIANT
WITH EXECUTE AS OWNER
AS
BEGIN

    DECLARE @retval INT
    DECLARE @null_column    SYSNAME
    
    SET @null_column = NULL

    IF (@name IS NULL OR @name = N'')
        SET @null_column = '@name'
    ELSE IF (@value IS NULL)
        SET @null_column = '@value'
    
    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_update_utility_configuration')
        RETURN(1)
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.sysutility_ucp_configuration_internal WHERE name = @name)
    BEGIN
        RAISERROR(14027, -1, -1, @name)
        RETURN(1)
    END

    UPDATE dbo.sysutility_ucp_configuration_internal SET current_value = @value WHERE name = @name
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
