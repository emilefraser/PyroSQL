SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[T000_Client](
	[MANDT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MTEXT] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ORT01] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MWAER] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ADRNR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCCATEGORY] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCCORACTIV] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCNOCLIIND] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCCOPYLOCK] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCNOCASCAD] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCSOFTLOCK] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCORIGCONT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCIMAILDIS] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCTEMPLOCK] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHANGEUSER] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHANGEDATE] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOGSYS] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
