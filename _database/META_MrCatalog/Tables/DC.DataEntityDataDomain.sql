SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataEntityDataDomain](
	[DataEntityDataDomainID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityID] [int] NOT NULL,
	[DataDomainID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
