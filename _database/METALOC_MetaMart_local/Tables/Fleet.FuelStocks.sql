SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Fleet].[FuelStocks](
	[RowId] [int] NULL,
	[CreatedDateTime] [datetime] NULL,
	[ModifiedDateTime] [datetime] NULL,
	[Deleted] [tinyint] NULL,
	[Asset] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateNow] [datetime] NULL,
	[FuelNow] [real] NULL,
	[PrevDate] [datetime] NULL,
	[PrevFuel] [real] NULL
) ON [PRIMARY]

GO
