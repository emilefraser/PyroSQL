SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bprac].[CodeSmells]') AND type in (N'U'))
BEGIN
CREATE TABLE [bprac].[CodeSmells](
	[SmellID] [int] IDENTITY(1,1) NOT NULL,
	[SmellCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SmellDecription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SmellTypeID] [int] NULL,
	[SmellProcedureName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SmellProcedureText] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime] NOT NULL,
	[UpdatedDT] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
