SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[DD08V_Generated_Table_for_View_DD08V_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[DD08V_Generated_Table_for_View_DD08V_PROD](
	[TABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FIELDNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDLANGUAGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHECKTABLE] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FRKART] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CLASFIELD] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CLASVALUE] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CARD] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHECKFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDTEXT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ARBGB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MSGNR] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NOINHERIT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CARDLEFT] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
