SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_SetFakeViewOff_SingleView]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_SetFakeViewOff_SingleView] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_SetFakeViewOff_SingleView]
  @ViewName NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Cmd NVARCHAR(MAX),
          @SchemaName NVARCHAR(MAX),
          @TriggerName NVARCHAR(MAX);
          
  SELECT @SchemaName = QUOTENAME(OBJECT_SCHEMA_NAME(ObjId)),
         @TriggerName = QUOTENAME(OBJECT_NAME(ObjId) + '_SetFakeViewOn')
    FROM (SELECT OBJECT_ID(@ViewName) AS ObjId) X;
  
  SET @Cmd = 'DROP TRIGGER %SCHEMA_NAME%.%TRIGGER_NAME%;';
      
  SET @Cmd = REPLACE(@Cmd, '%SCHEMA_NAME%', @SchemaName);
  SET @Cmd = REPLACE(@Cmd, '%TRIGGER_NAME%', @TriggerName);
  
  EXEC(@Cmd);
END;
GO
