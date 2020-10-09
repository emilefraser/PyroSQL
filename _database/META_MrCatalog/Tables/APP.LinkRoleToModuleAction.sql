SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[LinkRoleToModuleAction](
	[LinkRoleToModuleActionID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [int] NULL,
	[ModuleActionID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
