SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductDescriptionSAT](
	[ProductDescriptionVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Description] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
