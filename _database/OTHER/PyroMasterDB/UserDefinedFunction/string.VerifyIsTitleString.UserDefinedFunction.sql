SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyIsTitleString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[VerifyIsTitleString] (@string VARCHAR(MAX))   
/*
Select string.IsTitle(''How Many Times Must I Tell You'')
Select string.IsTitle(''this function is pretty useless'')
Select string.IsTitle(string.title(''this function is pretty useless''))
*/
RETURNS INT
AS BEGIN
      RETURN CASE 
           WHEN PATINDEX(''%[a-z][ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'', @string
                    COLLATE Latin1_General_CS_AI) > 0 THEN 0
           WHEN PATINDEX(''%[^A-Za-z][abcdefghijklmnopqrstuvwxyz]%'', @string 
                    COLLATE Latin1_General_CS_AI) > 0 THEN 0
                  ELSE 1
             END
   END
' 
END
GO
