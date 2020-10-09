SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_log_shipping_get_date_from_file 
  @db_name sysname,
  @filename NVARCHAR (500),
  @file_date DATETIME OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @tempname NVARCHAR (500)
  IF (LEN (@filename) - (LEN(@db_name) + LEN ('_tlog_')) <= 0)
    RETURN(1) -- filename string isn't long enough
  SELECT @tempname = RIGHT (@filename, LEN (@filename) - (LEN(@db_name) + LEN ('_tlog_')))
  IF (CHARINDEX ('.',@tempname,0) > 0)
    SELECT @tempname = LEFT (@tempname, CHARINDEX ('.',@tempname,0) - 1)
  IF (LEN (@tempname) <>  8 AND LEN (@tempname) <> 12)
    RETURN (1) -- error must be yyyymmddhhmm or yyyymmdd
  IF (ISNUMERIC (@tempname) = 0 OR CHARINDEX ('.',@tempname,0) <> 0 OR CONVERT (FLOAT,SUBSTRING (@tempname, 1,8)) < 1 )
    RETURN (1) -- must be numeric, can't contain any '.' etc
  SELECT @file_date = CONVERT (DATETIME,SUBSTRING (@tempname, 1,8),112)
  IF (LEN (@tempname) = 12)
  BEGIN
    SELECT @file_date = DATEADD (hh, CONVERT (INT, SUBSTRING (@tempname,9,2)),@file_date)
    SELECT @file_date = DATEADD (mi, CONVERT (INT, SUBSTRING (@tempname,11,2)),@file_date)
  END
  RETURN (0) -- success
END

GO
