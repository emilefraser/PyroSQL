SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductGroupSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Class] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Color] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProductLineName] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Size] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SizeUnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Style] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Weight] [decimal](18, 0) NULL,
	[WeightUnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
