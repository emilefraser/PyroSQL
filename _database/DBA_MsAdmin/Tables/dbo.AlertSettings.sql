SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AlertSettings](
	[AlertName] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VariableName] [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [bit] NULL,
	[Value] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
