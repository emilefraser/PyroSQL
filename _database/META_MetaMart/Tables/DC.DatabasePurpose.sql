SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabasePurpose](
	[DatabasePurposeID] [int] IDENTITY(1,1) NOT NULL,
	[DatabasePurposeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabasePurposeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabasePurposeDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
