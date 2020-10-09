SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DYNREP].[FieldDataValue](
	[FieldDataValueID] [int] IDENTITY(1,1) NOT NULL,
	[FieldDataValueGroupID] [int] NOT NULL,
	[LinkReportFieldID] [int] NOT NULL,
	[DataValue] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
