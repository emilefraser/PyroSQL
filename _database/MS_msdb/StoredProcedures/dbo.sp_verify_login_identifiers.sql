SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_verify_login_identifiers
   @login_name [nvarchar](256),
   @fixed_server_role [nvarchar](256),
   @msdb_role [nvarchar](256),
   @name [nvarchar](256) OUTPUT,
  @sid  varbinary(85)   OUTPUT,
   @flags   INT OUTPUT
AS
BEGIN
   DECLARE @retval         INT
    DECLARE @raise_error    bit
   SET NOCOUNT ON

   SELECT @flags = -1, @raise_error = 0
  SELECT @sid = NULL

  IF @login_name IS NOT NULL
   BEGIN
      --check validity
      --use the new optional parameter of SUSER_SID to have a case insensitive comparation for NT users
    SELECT @sid = SUSER_SID(@login_name, 0)
      IF @sid IS NULL
      BEGIN
         RAISERROR(14520, -1, -1, @login_name)
         RETURN(1) -- Failure
      END
      SELECT @name = @login_name, @flags = 0
   END

   IF COALESCE(@login_name, @fixed_server_role, @msdb_role) IS NULL
   BEGIN
      RAISERROR(14519, -1, -1)
      RETURN(1) -- Failure
   END

  IF @fixed_server_role IS NOT NULL  AND @flags <> -1
      SELECT @raise_error = 1
   ELSE IF @fixed_server_role IS NOT NULL
   --check validity
   BEGIN
      -- IS_SRVROLEMEMBER return NULL for an invalid server role
      IF ISNULL(IS_SRVROLEMEMBER(@fixed_server_role), -1) = -1
      BEGIN
         RAISERROR(14521, -1, -1, @fixed_server_role)
         RETURN(1) -- Failure
      END
      SELECT @name = @fixed_server_role, @flags = 1
    SELECT @sid = SUSER_SID(@fixed_server_role)
   END

  IF @msdb_role IS NOT NULL  AND @flags <> -1
      SELECT @raise_error = 1
   ELSE IF @msdb_role IS NOT NULL
   BEGIN
      --check the correctness of msdb role
      IF ISNULL(IS_MEMBER(@msdb_role), -1) = -1
      BEGIN
         RAISERROR(14522, -1, -1, @msdb_role)
         RETURN(1) -- Failure
      END
      SELECT @sid = sid from sys.database_principals
      WHERE  UPPER(@msdb_role collate SQL_Latin1_General_CP1_CS_AS) = UPPER(name collate SQL_Latin1_General_CP1_CS_AS)
    AND type = 'R'
    IF @sid IS NULL
      BEGIN
         RAISERROR(14522, -1, -1, @msdb_role)
         RETURN(1) -- Failure
      END
      SELECT @name = @msdb_role, @flags = 2
   END

   IF    @raise_error = 1
   BEGIN
      RAISERROR(14519, -1, -1)
      RETURN(1) -- Failure
   END

  RETURN(0) -- Success
END

GO
