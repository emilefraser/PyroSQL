SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestPattern]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[TestPattern](
	[PatternID] [int] IDENTITY(0,1) NOT NULL,
	[TestName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestDesription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestScope] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PatternID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF_test_TestPattern_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [test].[TestPattern] ADD  CONSTRAINT [DF_test_TestPattern_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
