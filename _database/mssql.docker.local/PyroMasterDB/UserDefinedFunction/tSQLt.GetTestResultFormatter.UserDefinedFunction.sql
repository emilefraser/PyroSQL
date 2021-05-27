SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[GetTestResultFormatter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[GetTestResultFormatter]()
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @FormatterName NVARCHAR(MAX);
    
    SELECT @FormatterName = CAST(value AS NVARCHAR(MAX))
    FROM sys.extended_properties
    WHERE name = N''tSQLt.ResultsFormatter''
      AND major_id = OBJECT_ID(''tSQLt.Private_OutputTestResults'');
      
    SELECT @FormatterName = COALESCE(@FormatterName, ''tSQLt.DefaultResultFormatter'');
    
    RETURN @FormatterName;
END;
' 
END
GO
