SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ModelDrill](
	[ModelDrillID] [uniqueidentifier] NOT NULL,
	[ModelID] [uniqueidentifier] NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[ModelItemID] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Type] [tinyint] NOT NULL
) ON [PRIMARY]

GO
