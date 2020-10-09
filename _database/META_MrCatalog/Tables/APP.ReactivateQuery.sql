SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[ReactivateQuery](
	[ReactivateQueryID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReactivateQueryString] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
