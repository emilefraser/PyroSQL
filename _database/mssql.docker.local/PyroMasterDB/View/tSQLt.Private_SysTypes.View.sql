SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_SysTypes]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [tSQLt].[Private_SysTypes] AS SELECT * FROM sys.types AS T;
' 
GO
