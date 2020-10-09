SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_get_instmdw]
AS
BEGIN
    -- only dc_admin and dbo can setup MDW
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14712, -1, -1) WITH LOG
        RETURN(1) -- Failure
    END

    -- if the script has not been loaded, load it now
    IF (NOT EXISTS(SELECT parameter_name 
                   FROM syscollector_blobs_internal
                   WHERE parameter_name = N'InstMDWScript'))
    BEGIN
        EXECUTE sp_syscollector_upload_instmdw
    END
               
    SELECT cast(parameter_value as nvarchar(max)) 
    FROM syscollector_blobs_internal
    WHERE parameter_name = N'InstMDWScript'
END

GO
