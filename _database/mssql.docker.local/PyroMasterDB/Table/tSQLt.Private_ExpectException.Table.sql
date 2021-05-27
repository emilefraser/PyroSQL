SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ExpectException]') AND type in (N'U'))
BEGIN
CREATE TABLE [tSQLt].[Private_ExpectException](
	[i] [int] NULL
) ON [PRIMARY]
END
GO
