SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ApplyUniqueConstraint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_ApplyUniqueConstraint] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_ApplyUniqueConstraint] 
  @ConstraintObjectId INT
AS
BEGIN
  DECLARE @SchemaName NVARCHAR(MAX);
  DECLARE @OrgTableName NVARCHAR(MAX);
  DECLARE @TableName NVARCHAR(MAX);
  DECLARE @ConstraintName NVARCHAR(MAX);
  DECLARE @CreateConstraintCmd NVARCHAR(MAX);
  DECLARE @AlterColumnsCmd NVARCHAR(MAX);
  
  SELECT @SchemaName = SchemaName,
         @OrgTableName = OrgTableName,
         @TableName = TableName,
         @ConstraintName = OBJECT_NAME(@ConstraintObjectId)
    FROM tSQLt.Private_GetQuotedTableNameForConstraint(@ConstraintObjectId);
      
  SELECT @AlterColumnsCmd = NotNullColumnCmd,
         @CreateConstraintCmd = CreateConstraintCmd
    FROM tSQLt.Private_GetUniqueConstraintDefinition(@ConstraintObjectId, QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName));

  EXEC tSQLt.Private_RenameObjectToUniqueName @SchemaName, @ConstraintName;
  EXEC (@AlterColumnsCmd);
  EXEC (@CreateConstraintCmd);
END;
GO
