SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[ModuleControlInformation](
	[ModuleControlInformationID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[ControlName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InformationCode] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InformationDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
