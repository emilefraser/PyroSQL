SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[CompanyLeadPosition](
	[CompanyLeadPositionID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[LeadEmployeePositionID] [int] NOT NULL
) ON [PRIMARY]

GO
