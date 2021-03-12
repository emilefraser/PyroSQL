SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[DD04V_Generated_Table_for_View_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[DD04V_Generated_Table_for_View_PROD](
	[ROLLNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDLANGUAGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ROUTPUTLEN] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MEMORYID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOGFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HEADLEN] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN1] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN2] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN3] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDTEXT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REPTEXT] [nvarchar](55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_S] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_M] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_L] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ACTFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APPLCLASS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUTHCLASS] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4USER] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4DATE] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4TIME] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DTELMASTER] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RESERVEDTE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DTELGLOBAL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SHLPNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SHLPFIELD] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DEFFDNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATATYPE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LENG] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DECIMALS] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OUTPUTLEN] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOWERCASE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SIGNFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CONVEXIT] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALEXI] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ENTITYTAB] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFKIND] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFTYPE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PROXYTYPE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LTRFLDDIS] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BIDICTRLC] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NOHISTORY] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
