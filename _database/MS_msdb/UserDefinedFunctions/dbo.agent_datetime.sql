SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE FUNCTION agent_datetime(@date int, @time int)
RETURNS DATETIME
AS
BEGIN
 RETURN
  (
    CONVERT(DATETIME,
          CONVERT(NVARCHAR(4),@date / 10000) + N'-' +
          CONVERT(NVARCHAR(2),(@date % 10000)/100)  + N'-' +
          CONVERT(NVARCHAR(2),@date % 100) + N' ' +
          CONVERT(NVARCHAR(2),@time / 10000) + N':' +
          CONVERT(NVARCHAR(2),(@time % 10000)/100) + N':' +
          CONVERT(NVARCHAR(2),@time % 100),
    120)
  )
END

GO
