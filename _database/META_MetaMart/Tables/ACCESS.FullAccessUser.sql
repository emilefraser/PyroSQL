SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[FullAccessUser](
	[FullAccessUserID] [int] IDENTITY(1,1) NOT NULL,
	[DomainAccountOrGroup] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsFullAccessUser] [bit] NOT NULL,
	[IsDeveloper] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
