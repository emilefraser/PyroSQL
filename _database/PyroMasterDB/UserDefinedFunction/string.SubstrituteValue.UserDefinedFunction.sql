SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SubstrituteValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[SubstrituteValue] (@String VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS BEGIN
    DECLARE @substitutions TABLE
      (
       before VARCHAR(12),
       After VARCHAR(12)
      )
    INSERT  INTO @substitutions (before, after)
              SELECT  '' was '','' were ''
              UNION SELECT  '' wasn''''t'','' weren''''t''
              UNION SELECT  '' me '','' you ''
              UNION SELECT  '' my '','' your ''
              UNION SELECT  '' I '','' You ''
              UNION SELECT  '' I''''ve '','' You''''ve ''
    SELECT  @string = LTRIM(REPLACE('' '' + @String + '' '',
                                    before, after))
        FROM    @substitutions
    RETURN @String
   END
' 
END
GO
