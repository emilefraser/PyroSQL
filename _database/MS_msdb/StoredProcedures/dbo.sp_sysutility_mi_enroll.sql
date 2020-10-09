SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
CREATE PROCEDURE [dbo].[sp_sysutility_mi_enroll]
WITH EXECUTE AS OWNER
AS
BEGIN
    /* Validate that the local instance can be managed by a UCP. */
    EXEC [dbo].[sp_sysutility_mi_validate_enrollment_preconditions]
END 

GO
