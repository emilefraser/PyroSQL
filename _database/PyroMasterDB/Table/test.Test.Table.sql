SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[Test]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[Test](
	[TestId] [int] IDENTITY(0,1) NOT NULL,
	[TestCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestDescription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestClassId] [int] NOT NULL,
	[TestTypeId] [int] NOT NULL,
	[ObjectType] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF__Test__CreatedDT__442B18F2]') AND type = 'D')
BEGIN
ALTER TABLE [test].[Test] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
