SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TestPerformance](
	[TestID] [int] IDENTITY(1,1) NOT NULL,
	[TestDateTime] [datetime2](7) NULL,
	[TestInteger] [int] NULL,
	[TestVarchar] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
