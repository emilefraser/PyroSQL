SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[ApplyTrigger]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[ApplyTrigger] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[ApplyTrigger]
  @TableName NVARCHAR(MAX),
  @TriggerName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @OrgTableObjectId INT;
  SELECT @OrgTableObjectId = OrgTableObjectId FROM tSQLt.Private_GetOriginalTableInfo(OBJECT_ID(@TableName)) orgTbl
  IF(@OrgTableObjectId IS NULL)
  BEGIN
    RAISERROR('%s does not exist or was not faked by tSQLt.FakeTable.', 16, 10, @TableName);
  END;
  
  DECLARE @FullTriggerName NVARCHAR(MAX);
  DECLARE @TriggerObjectId INT;
  SELECT @FullTriggerName = QUOTENAME(SCHEMA_NAME(schema_id))+'.'+QUOTENAME(name), @TriggerObjectId = object_id
  FROM sys.objects WHERE PARSENAME(@TriggerName,1) = name AND parent_object_id = @OrgTableObjectId;
  
  DECLARE @TriggerCode NVARCHAR(MAX);
  SELECT @TriggerCode = m.definition
    FROM sys.sql_modules m
   WHERE m.object_id = @TriggerObjectId;
  
  IF (@TriggerCode IS NULL)
  BEGIN
    RAISERROR('%s is not a trigger on %s', 16, 10, @TriggerName, @TableName);
  END;
 
  EXEC tSQLt.RemoveObject @FullTriggerName;
  
  EXEC(@TriggerCode);
END;


GO
