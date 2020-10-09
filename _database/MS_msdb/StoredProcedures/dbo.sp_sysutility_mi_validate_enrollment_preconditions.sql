SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
CREATE PROCEDURE [dbo].[sp_sysutility_mi_validate_enrollment_preconditions]
WITH EXECUTE AS OWNER
AS
BEGIN
    /* Get the Edition value */
    DECLARE @edition NVARCHAR(64)
    SELECT @edition = Convert(NVARCHAR, SERVERPROPERTY('edition'))

    /* Check SQLBOOT to ensure this instance edition can be used as a UCP. */
    DECLARE @sqlbootvalue int

    EXEC @sqlbootvalue = master.dbo.xp_qv '3090395820', @@SERVICENAME
    IF (@sqlbootvalue = 2)
        RAISERROR ('Instance can be managed by a Utility Control Point.', 0, 1) WITH NOWAIT;
    ELSE
        RAISERROR(37005, -1, -1, @edition)
        RETURN(1)
END 

GO
