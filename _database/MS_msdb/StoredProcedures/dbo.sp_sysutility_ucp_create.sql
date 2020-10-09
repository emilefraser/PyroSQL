SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_create]
WITH EXECUTE AS OWNER
AS
BEGIN
    /* Validate that the UCP can be created on the local instance. */
    EXEC [dbo].[sp_sysutility_ucp_validate_prerequisites]
END 

GO
