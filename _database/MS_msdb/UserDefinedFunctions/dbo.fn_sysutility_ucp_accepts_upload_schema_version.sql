SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_accepts_upload_schema_version] 
(
    @upload_schema_version INT
)
RETURNS INT
AS
BEGIN

   DECLARE @accepted_min_version INT = 100;
   DECLARE @accepted_max_version INT = 100;
   
   -- Assume that the version is compatable
   DECLARE @retvalue INT = 0;
   
   IF(@upload_schema_version < @accepted_min_version)
      SET @retvalue = -1
   ELSE IF(@upload_schema_version > @accepted_max_version)
      SET @retvalue = 1
      
   RETURN @retvalue
   
END

GO
