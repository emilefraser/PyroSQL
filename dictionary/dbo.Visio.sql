SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Visio](
	[ShapeKey] [int] NULL,
	[Shape.Text] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data1] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data2] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shape.Data3] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvStructureType] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListDirection] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListItemMaster1] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListItemMaster2] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListItemMaster3] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListItemMaster4] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_msvSDListRequiredCategories] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_ShowType] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_Test] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_EntityName] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_EntityNameSpace] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_AttributeName] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_PrimaryKey] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_ForeignKey] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_Required] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[User_AttributeType] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
