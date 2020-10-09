SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LocationSAT](
	[LocationVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Availability] [decimal](18, 0) NOT NULL,
	[CostRate] [smallmoney] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
