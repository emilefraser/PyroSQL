SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ServerParametersInstance](
	[ServerParametersID] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ParentID] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Path] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[Timeout] [int] NOT NULL,
	[Expiration] [datetime] NOT NULL,
	[ParametersValues] [image] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
