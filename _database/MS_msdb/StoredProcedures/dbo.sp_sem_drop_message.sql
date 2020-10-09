SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sem_drop_message
  @msgnum int     = NULL,
  @lang   sysname = NULL -- Message language name
AS
BEGIN
  DECLARE @retval        INT
  DECLARE @language_name sysname

  SET NOCOUNT ON

  SET ROWCOUNT 1
  SELECT @language_name = name
  FROM sys.syslanguages
  WHERE msglangid = (SELECT number
                     FROM master.dbo.spt_values
                     WHERE (type = 'LNG')
                       AND (name = @lang))
  SET ROWCOUNT 0

  SELECT @language_name = ISNULL(@language_name, 'us_english')
  EXECUTE @retval = master.dbo.sp_dropmessage @msgnum, @language_name
  RETURN(@retval)
END

GO
