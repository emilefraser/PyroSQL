SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[TestCaseSummary]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [tSQLt].[TestCaseSummary]()
RETURNS TABLE
AS
RETURN WITH A(Cnt, SuccessCnt, FailCnt, ErrorCnt) AS (
                SELECT COUNT(1),
                       ISNULL(SUM(CASE WHEN Result = ''Success'' THEN 1 ELSE 0 END), 0),
                       ISNULL(SUM(CASE WHEN Result = ''Failure'' THEN 1 ELSE 0 END), 0),
                       ISNULL(SUM(CASE WHEN Result = ''Error'' THEN 1 ELSE 0 END), 0)
                  FROM tSQLt.TestResult
                  
                )
       SELECT ''Test Case Summary: '' + CAST(Cnt AS NVARCHAR) + '' test case(s) executed, ''+
                  CAST(SuccessCnt AS NVARCHAR) + '' succeeded, ''+
                  CAST(FailCnt AS NVARCHAR) + '' failed, ''+
                  CAST(ErrorCnt AS NVARCHAR) + '' errored.'' Msg,*
         FROM A;
' 
END
GO
