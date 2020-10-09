SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[PersonAccessControlList](
	[PersonAccessControlListID] [int] IDENTITY(1,1) NOT NULL,
	[OrgChartPositionID] [int] NULL,
	[PersonNonEmployeeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
