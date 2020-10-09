SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [tSQLt].[Private_RenamedObjectLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[OriginalName] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
