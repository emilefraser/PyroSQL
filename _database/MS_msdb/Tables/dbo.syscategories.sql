SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscategories](
	[category_id] [int] IDENTITY(1,1) NOT NULL,
	[category_class] [int] NOT NULL,
	[category_type] [tinyint] NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
