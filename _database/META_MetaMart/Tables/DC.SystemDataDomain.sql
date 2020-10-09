SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[SystemDataDomain](
	[SystemDataDomainID] [int] IDENTITY(1,1) NOT NULL,
	[SystemID] [int] NULL,
	[DataDomainID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[isActive] [bit] NULL
) ON [PRIMARY]

GO
