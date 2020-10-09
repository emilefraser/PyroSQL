SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [config].[GenericHistory](
	[ConfigID] [int] NOT NULL,
	[ConfigCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ConfigDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValue] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValueType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
