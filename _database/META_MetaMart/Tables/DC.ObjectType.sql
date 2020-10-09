SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[ObjectType](
	[ObjectTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
