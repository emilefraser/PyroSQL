SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadProcExports](
	[LoadProcID] [int] IDENTITY(1,1) NOT NULL,
	[LoadConfigID] [int] NOT NULL,
	[TableName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Author] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[RunNumber] [int] NULL,
	[IsLastRun] [bit] NULL,
	[Status] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StoredProcName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
