SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Testy]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Testy](
	[id] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[val] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
