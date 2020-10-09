SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_uniquetaskname
  @seed NVARCHAR(92)
AS
BEGIN
  DECLARE @newest_suffix INT

  SET NOCOUNT ON

  -- We're going to add a suffix of 8 characters so make sure the seed is at most 84 characters
  SELECT @seed = LTRIM(RTRIM(@seed))
  IF (DATALENGTH(@seed) > 0)
    SELECT @seed = SUBSTRING(@seed, 1, 84)

  -- Find the newest (highest) suffix so far
  SELECT @newest_suffix = MAX(CONVERT(INT, RIGHT(name, 8)))
  FROM msdb.dbo.sysjobs -- DON'T use sysjobs_view here!
  WHERE (name LIKE N'%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

  -- Generate the task name by appending the 'newest suffix' value (plus one) to the seed
  IF (@newest_suffix IS NOT NULL)
  BEGIN
    SELECT @newest_suffix = @newest_suffix + 1
    SELECT 'TaskName' = CONVERT(NVARCHAR(92), @seed + REPLICATE(N'0', 8 - (DATALENGTH(CONVERT(NVARCHAR, @newest_suffix)) / 2)) + CONVERT(NVARCHAR, @newest_suffix))
  END
  ELSE
    SELECT 'TaskName' = CONVERT(NVARCHAR(92), @seed + N'00000001')
END

GO
