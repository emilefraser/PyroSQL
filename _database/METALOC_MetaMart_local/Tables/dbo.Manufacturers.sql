SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Manufacturers](
	[ManufacturerId] [int] NULL,
	[Name] [nvarchar](510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsDeleted] [bit] NULL
) ON [PRIMARY]

GO
