SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[VerbHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [mssql].[VerbHistory](
	[VerbID] [smallint] NOT NULL,
	[VerbCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
