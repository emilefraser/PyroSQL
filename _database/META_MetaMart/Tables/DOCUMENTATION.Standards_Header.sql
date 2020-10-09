SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DOCUMENTATION].[Standards_Header](
	[StandardsID] [int] IDENTITY(1,1) NOT NULL,
	[StandardsCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StandardsName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StandardsDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StandardPurposeDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsAtive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
