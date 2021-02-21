SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetPosition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[GetPosition] (
	@strInput     VARCHAR(8000)
  , @delimiter    VARCHAR(50)) 
RETURNS TABLE
AS
	RETURN

	WITH findchar(
		[posnum]
	  , [pos])
		 AS (SELECT 
				 1 AS [posnum]
			   , CHARINDEX(@delimiter, @strInput) AS [pos]
			 UNION ALL
			 SELECT   
				 [f].[posnum] + 1 AS [posnum]
			   , CHARINDEX(@delimiter, @strInput, [f].[pos] + 1) AS [pos]
			 FROM   
				 [findchar] AS [f]
			 WHERE [f].[posnum] + 1 <= LEN(@strInput)
				   AND [pos] <> 0)
		 SELECT   
			 [posnum]
		   , [pos]
		 FROM   
			 [findchar]
		 WHERE [pos] > 0;

' 
END
GO
