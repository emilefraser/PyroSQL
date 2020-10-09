SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DOCUMENTATION].[Standards_Detail](
	[StandardsDetailID] [int] IDENTITY(1,1) NOT NULL,
	[StandardsID] [int] NULL,
	[StandardsLineNo] [int] NULL,
	[StandardsLineSortOrder] [int] NULL,
	[StandardsLineDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
