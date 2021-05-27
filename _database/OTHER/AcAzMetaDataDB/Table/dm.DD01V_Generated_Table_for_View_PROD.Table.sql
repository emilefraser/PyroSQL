SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[DD01V_Generated_Table_for_View_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[DD01V_Generated_Table_for_View_PROD](
	[DOMNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDLANGUAGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATATYPE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LENG] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OUTPUTLEN] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DECIMALS] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOWERCASE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SIGNFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALEXI] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ENTITYTAB] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CONVEXIT] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MASK] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MASKLEN] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDTEXT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ACTFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APPLCLASS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUTHCLASS] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4USER] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4DATE] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AS4TIME] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMMASTER] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RESERVEDOM] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMGLOBAL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APPENDNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[APPEXIST] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PROXYTYPE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OUTPUTSTYLE] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AMPMFORMAT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
