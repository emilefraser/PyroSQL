SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Fleet].[AllHoursProd](
	[RowId] [int] NULL,
	[CreatedDateTime] [datetime] NULL,
	[ModifiedDateTime] [datetime] NULL,
	[Deleted] [tinyint] NULL,
	[AssetCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hours] [real] NULL,
	[Date] [datetime] NULL
) ON [PRIMARY]

GO
