SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

-- check if a login is member of NT group\database role
--
-- if we specify a NT group SID @login_sid should be NOT NULL
--
-- if a @role_principal_id is specified, a NULL login is allowed
-- in this case we check if the msdb database user associated
-- with the current security context is member of the specified
-- msdb database role (this allows us to verify if a particular
-- msdb database loginless msdb user is member of that msdb role)
CREATE PROCEDURE dbo.sp_sqlagent_is_member
(
  @group_sid VARBINARY(85) = NULL,
   @role_principal_id  INT = NULL,
   @login_sid VARBINARY(85)
)
AS
BEGIN
   DECLARE @ret_success  INT
  DECLARE @login        NVARCHAR(256)
   DECLARE @impersonated INT
  DECLARE @group_name   NVARCHAR(256)
   SELECT   @ret_success = 0 --failure
  SELECT  @impersonated = 0

  IF (@group_sid IS NOT NULL AND @login_sid IS NULL)
    RETURN(0)

  --a sysadmin can check for every user group membership
  IF (@login_sid IS NOT NULL) AND (ISNULL(IS_SRVROLEMEMBER('sysadmin'),0) = 1)
  BEGIN
    --get login name from principal_id
    SELECT @login = SUSER_SNAME(@login_sid)

    IF SUSER_SNAME() <> @login
    BEGIN
       --impersonate
        EXECUTE sp_setuserbylogin @login
      SELECT @impersonated = 1
    END
  END

  IF @group_sid IS NOT NULL
    SELECT @group_name = SUSER_SNAME(@group_sid)
  ELSE
    SELECT @group_name = USER_NAME(@role_principal_id)

   -- return success, if login is member of the group, and failure if group doesnt exist or login is not member of the group
   SELECT  @ret_success = ISNULL(IS_MEMBER(@group_name),0)

   --revert to self
  IF @impersonated = 1
         EXECUTE sp_setuserbylogin

   RETURN @ret_success
END

GO
