SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_IsTestClass]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[Private_IsTestClass](@TestClassName NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
  RETURN 
    CASE 
      WHEN EXISTS(
             SELECT 1 
               FROM tSQLt.TestClasses
              WHERE SchemaId = tSQLt.Private_GetSchemaId(@TestClassName)
            )
      THEN 1
      ELSE 0
    END;
END;
' 
END
GO
