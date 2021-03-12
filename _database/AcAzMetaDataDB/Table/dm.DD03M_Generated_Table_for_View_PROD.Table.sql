SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[DD03M_Generated_Table_for_View_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[DD03M_Generated_Table_for_View_PROD](
	[TABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FIELDNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FLDSTAT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ROLLNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ROLLSTAT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMSTAT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TEXTSTAT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDLANGUAGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[POSITION] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[KEYFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MANDATORY] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHECKTABLE] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ADMINFIELD] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[INTTYPE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[INTLEN] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFTABLE] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRECFIELD] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFFIELD] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CONROUT] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ROUTPUTLEN] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MEMORYID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOGFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HEADLEN] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN1] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN2] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRLEN3] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DTELGLOBAL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DTELMASTER] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RESERVEDTE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[ACTFLAG] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMMASTER] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RESERVEDOM] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOMGLOBAL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DDTEXT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REPTEXT] [nvarchar](55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_S] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_M] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCRTEXT_L] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_DD03M] PRIMARY KEY CLUSTERED 
(
	[TABNAME] ASC,
	[DDLANGUAGE] ASC,
	[FIELDNAME] ASC,
	[POSITION] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dm].[DD03M_Generated_Table_for_View_PROD]') AND name = N'ncix01_DD03M')
CREATE NONCLUSTERED INDEX [ncix01_DD03M] ON [dm].[DD03M_Generated_Table_for_View_PROD]
(
	[DDLANGUAGE] ASC
)
INCLUDE([TABNAME],[FIELDNAME],[DDTEXT],[KEYFLAG],[MANDATORY],[INTTYPE],[DATATYPE],[LENG],[INTLEN],[DECIMALS],[REFTABLE],[POSITION],[REPTEXT],[SCRTEXT_S],[SCRTEXT_M],[SCRTEXT_L]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dm].[DD03M_Generated_Table_for_View_PROD]') AND name = N'ncix02_DD03M')
CREATE NONCLUSTERED INDEX [ncix02_DD03M] ON [dm].[DD03M_Generated_Table_for_View_PROD]
(
	[TABNAME] ASC,
	[POSITION] ASC
)
INCLUDE([DDLANGUAGE],[FIELDNAME],[DDTEXT],[KEYFLAG],[MANDATORY],[INTTYPE],[DATATYPE],[LENG],[INTLEN],[DECIMALS],[REFTABLE],[REPTEXT],[SCRTEXT_S],[SCRTEXT_M],[SCRTEXT_L]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
