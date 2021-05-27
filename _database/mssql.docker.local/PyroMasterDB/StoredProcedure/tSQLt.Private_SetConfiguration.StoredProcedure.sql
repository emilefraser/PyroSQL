SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_SetConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_SetConfiguration] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_SetConfiguration]
  @Name NVARCHAR(100),
  @Value SQL_VARIANT
AS
BEGIN
  IF(EXISTS(SELECT 1 FROM tSQLt.Private_Configurations WITH(ROWLOCK,UPDLOCK) WHERE Name = @Name))
  BEGIN
    UPDATE tSQLt.Private_Configurations SET
           Value = @Value
     WHERE Name = @Name;
  END;
  ELSE
  BEGIN
     INSERT tSQLt.Private_Configurations(Name,Value)
     VALUES(@Name,@Value);
  END;
END;
GO
