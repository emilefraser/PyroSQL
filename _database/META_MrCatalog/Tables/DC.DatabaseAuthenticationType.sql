SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabaseAuthenticationType](
	[DatabaseAuthenticationTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DBAuthTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
