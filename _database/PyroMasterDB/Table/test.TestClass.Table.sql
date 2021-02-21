SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestClass]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[TestClass](
	[TestClassId] [smallint] IDENTITY(0,1) NOT NULL,
	[TestClassCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestClassName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TestClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF__TestClass__Creat__3B95D2F1]') AND type = 'D')
BEGIN
ALTER TABLE [test].[TestClass] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
