SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[LinkPersonWithRoleToDataDomain](
	[LinkPersonWithRoleToDataDomainID] [int] IDENTITY(1,1) NOT NULL,
	[PersonAccessControlListID] [int] NULL,
	[RoleID] [int] NULL,
	[DataDomainID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
