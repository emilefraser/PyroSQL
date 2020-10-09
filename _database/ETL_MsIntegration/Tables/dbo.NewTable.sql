SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NewTable](
	[ShapeKey] [int] NULL,
	[Shape.Text] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data1] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data2] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data3] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_EntityName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_EntityNameSpace] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_PrimaryKey] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_ForeignKey] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_Required] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
