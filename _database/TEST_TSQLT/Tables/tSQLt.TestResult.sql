SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [tSQLt].[TestResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Class] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestCase] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name]  AS ((quotename([Class])+'.')+quotename([TestCase])),
	[TranName] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Result] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Msg] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestStartTime] [datetime] NOT NULL,
	[TestEndTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
