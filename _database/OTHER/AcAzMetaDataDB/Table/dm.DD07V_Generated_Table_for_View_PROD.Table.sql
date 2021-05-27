SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[DD07V_Generated_Table_for_View_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[DD07V_Generated_Table_for_View_PROD](
	[DOMNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALPOS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDLANGUAGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMVALUE_L] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMVALUE_H] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDTEXT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMVAL_LD] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMVAL_HD] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APPVAL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
