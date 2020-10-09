SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[Validation_InfoMart_Views](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InfoMartDatabaseName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ViewSchema] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ViewName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ValidationStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ValidationMessage] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastValidationDate] [datetime] NULL
) ON [PRIMARY]

GO
