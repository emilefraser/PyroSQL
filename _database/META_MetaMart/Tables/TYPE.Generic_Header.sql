SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [TYPE].[Generic_Header](
	[HeaderID] [int] IDENTITY(1,1) NOT NULL,
	[HeaderCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HeaderTypeGroupName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[Modified] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
