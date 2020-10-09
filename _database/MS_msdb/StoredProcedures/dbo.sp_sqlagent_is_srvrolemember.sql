SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_sqlagent_is_srvrolemember
   @role_name sysname, @login_name sysname
AS
BEGIN
  DECLARE @is_member        INT
  SET NOCOUNT ON

  IF @role_name IS NULL OR @login_name IS NULL
    RETURN(0)

  SELECT @is_member = 0
  --IS_SRVROLEMEMBER works only if the login to be tested is provisioned with sqlserver
  if( @login_name = SUSER_SNAME())
    SELECT @is_member = IS_SRVROLEMEMBER(@role_name)
  else
    SELECT @is_member = IS_SRVROLEMEMBER(@role_name, @login_name)


  --try to impersonate. A try catch is used because we can have @name as NT groups also
  IF @is_member IS NULL
  BEGIN
    BEGIN TRY
      if( is_srvrolemember('sysadmin') = 1)
      begin
      EXECUTE AS LOGIN = @login_name -- impersonate
        SELECT @is_member = IS_SRVROLEMEMBER(@role_name)  -- check role membership
      REVERT -- revert back
      end
    END TRY
    BEGIN CATCH
      SELECT @is_member = 0
    END CATCH
  END

  RETURN ISNULL(@is_member,0)
END

GO
