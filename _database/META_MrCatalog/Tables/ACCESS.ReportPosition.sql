SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportPosition](
	[ReportPositionID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeePositionID] [int] NULL,
	[NonEmployeeReportUserID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
