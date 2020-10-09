SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabaseInstance](
	[DatabaseInstanceID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseInstanceName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServerID] [int] NOT NULL,
	[DatabaseAuthenticationTypeID] [int] NOT NULL,
	[AuthUsername] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuthPassword] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsDefaultInstance] [bit] NULL,
	[NetworkPort] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[ADFLinkedServiceID] [int] NULL,
	[DatabaseTechnologyTypeID] [int] NULL
) ON [PRIMARY]

GO
