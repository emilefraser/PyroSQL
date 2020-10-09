SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CONFIG.Generic](
	[ConfigID] [int] IDENTITY(1,1) NOT NULL,
	[ConfigCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValue] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigvalueType] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
