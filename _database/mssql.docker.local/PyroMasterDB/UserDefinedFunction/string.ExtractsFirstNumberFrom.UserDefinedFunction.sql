SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[ExtractsFirstNumberFrom]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
SELECT  dbo.ufsFirstNumberFrom(''valve no. 345 open'')
SELECT  dbo.ufsFirstNumberFrom(''valve no. 345.23 is open'')
*/
CREATE FUNCTION [string].[ExtractsFirstNumberFrom] (@String VARCHAR(MAX))
RETURNS VARCHAR(40)
AS BEGIN
    DECLARE @numberStart INT,
      @numberEnd INT
    SELECT  @numberStart = PATINDEX(''%[0-9]%'',
          @String  COLLATE Latin1_General_Ci_AI)
    SELECT  @numberEnd = PATINDEX(''%[0-9][^0-9.]%'',
           @String + ''|''  COLLATE Latin1_General_Ci_AI)
    RETURN CASE WHEN @numberStart = 0 OR @numberend = 0
                THEN ''''
                ELSE SUBSTRING(@String, @numberStart,
                         1 + @numberEnd - @numberStart)
           END
   END
' 
END
GO
