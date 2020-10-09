SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[ServerType](
	[ServerTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ServerTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServerTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
