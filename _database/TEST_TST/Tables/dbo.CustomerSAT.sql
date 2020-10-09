SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomerSAT](
	[CustomerVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AccountNumber] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
