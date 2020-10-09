SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CTE].[FiltersCTE_Demo](
	[ICFilterID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [int] NOT NULL,
	[FilterDesc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Active] [tinyint] NOT NULL
) ON [PRIMARY]

GO