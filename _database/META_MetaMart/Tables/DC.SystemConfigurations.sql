SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[SystemConfigurations](
	[SystemConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SystemID] [int] NOT NULL,
	[ConfigurationType] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigurationDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigurationValue] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedBy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedBy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
