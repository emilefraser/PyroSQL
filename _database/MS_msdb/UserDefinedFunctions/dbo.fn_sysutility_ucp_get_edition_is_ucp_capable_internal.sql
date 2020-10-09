SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION dbo.fn_sysutility_ucp_get_edition_is_ucp_capable_internal ()
RETURNS bit
AS
BEGIN
   DECLARE @is_instance_ucp_capable bit = 1;
   -- The integer value below corresponds to a SQLBOOT property that identifies whether 
   -- the SKU supports the UCP feature.  
   DECLARE @sqlbootvalue int;
   EXEC @sqlbootvalue = master.dbo.xp_qv '1675385081', @@SERVICENAME;
   IF (@sqlbootvalue != 2)
   BEGIN
      SET @is_instance_ucp_capable = 0;
   END;
   RETURN @is_instance_ucp_capable;
END 

GO
