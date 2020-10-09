SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_enum_proxy_for_subsystem
   @proxy_id      int = NULL,
   @proxy_name    sysname = NULL,
   -- must specify only one of above parameter to identify the proxy or none
   @subsystem_id  int = NULL,
   @subsystem_name sysname = NULL
   -- must specify only one of above parameter to identify the subsystem or none
AS
BEGIN
   DECLARE @retval   INT
   SET NOCOUNT ON

   -- Remove any leading/trailing spaces from parameters
   SELECT @subsystem_name          = LTRIM(RTRIM(@subsystem_name))
   SELECT @proxy_name              = LTRIM(RTRIM(@proxy_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF @subsystem_name    = '' SELECT @subsystem_name = NULL
  IF @proxy_name         = '' SELECT @proxy_name = NULL

   IF @proxy_name IS NOT NULL OR @proxy_id IS NOT NULL
   BEGIN
      EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                          '@proxy_id',
                                          @proxy_name OUTPUT,
                                          @proxy_id   OUTPUT
      IF (@retval <> 0)
   RETURN(1) -- Failure
   END

   IF @subsystem_name IS NOT NULL OR @subsystem_id IS NOT NULL
   BEGIN
      EXECUTE @retval = sp_verify_subsystem_identifiers '@subsystem_name',
                                       '@subsystem_id',
                                       @subsystem_name OUTPUT,
                                       @subsystem_id   OUTPUT
      IF (@retval <> 0)
      RETURN(1) -- Failure
   END

  SELECT ps.subsystem_id AS subsystem_id, s.subsystem AS subsystem_name, ps.proxy_id AS proxy_id, p.name AS proxy_name
   FROM sysproxysubsystem ps JOIN sysproxies p ON ps.proxy_id = p.proxy_id
  JOIN syssubsystems s ON ps.subsystem_id = s.subsystem_id
   WHERE
        ISNULL(@subsystem_id, ps.subsystem_id) = ps.subsystem_id AND
        ISNULL(@proxy_id,     ps.proxy_id    ) = ps.proxy_id
END

GO
