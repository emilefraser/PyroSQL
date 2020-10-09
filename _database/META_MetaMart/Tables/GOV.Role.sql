SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[Role](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleCode] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RoleDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
