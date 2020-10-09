SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[DataDomain](
	[DataDomainID] [int] IDENTITY(1,1) NOT NULL,
	[DataDomainCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataDomainDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataDomainParentID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
