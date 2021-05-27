SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_NullCellTable]') AND type in (N'U'))
BEGIN
CREATE TABLE [tSQLt].[Private_NullCellTable](
	[I] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_NullCellTable_StopDeletes]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [tSQLt].[Private_NullCellTable_StopDeletes] ON [tSQLt].[Private_NullCellTable] INSTEAD OF DELETE, INSERT, UPDATE
AS
BEGIN
  RETURN;
END;
' 
GO
ALTER TABLE [tSQLt].[Private_NullCellTable] ENABLE TRIGGER [Private_NullCellTable_StopDeletes]
GO
