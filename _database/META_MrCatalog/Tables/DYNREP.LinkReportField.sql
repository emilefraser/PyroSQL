SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DYNREP].[LinkReportField](
	[LinkReportFieldID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[FieldID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
