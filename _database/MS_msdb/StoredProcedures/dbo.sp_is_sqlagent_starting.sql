SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_is_sqlagent_starting
AS
BEGIN
  DECLARE @retval INT

  SELECT @retval = 0
  EXECUTE master.dbo.xp_sqlagent_is_starting @retval OUTPUT
  IF (@retval = 1)
    RAISERROR(14258, -1, -1)

  RETURN(@retval)
END

GO
