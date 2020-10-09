SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[Server](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerLocation] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PublicIP] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LocalIP] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UserID] [int] NULL,
	[AccessInstructions] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[ServerTypeID] [int] NULL,
	[ServerLocationID] [int] NULL
) ON [PRIMARY]

GO
