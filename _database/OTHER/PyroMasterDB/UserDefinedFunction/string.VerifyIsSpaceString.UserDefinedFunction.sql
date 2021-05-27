SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyIsSpaceString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[VerifyIsSpaceString](@string VARCHAR(MAX))   
/*
Select string.VerifyIsSpaceString(''how many times must i tell you'')
Select string.VerifyIsSpaceString('' <>[]{}"!@#$%9  )))))))'')
Select string.VerifyIsSpaceString('' ????/>.<,'')*/
RETURNS INT
AS BEGIN
      RETURN CASE WHEN PATINDEX(
              ''%[A-Za-z0-9-]%'', @string  COLLATE Latin1_General_CS_AI
                                ) > 0 THEN 0
                  ELSE 1
             END
   END
' 
END
GO
