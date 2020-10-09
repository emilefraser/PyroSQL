SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabaseTypeFieldOptions](
	[DatabaseTypeFieldOptionsID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseTypeFieldOptionsCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseTypeFieldOptionsName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
