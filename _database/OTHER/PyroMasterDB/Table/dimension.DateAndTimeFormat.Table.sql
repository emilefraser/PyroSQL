SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[DateAndTimeFormat]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[DateAndTimeFormat](
	[DateAndTimeFormatId] [int] IDENTITY(0,1) NOT NULL,
	[DateValueName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateTypeName] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DateFormatExpression] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateFormatValue] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateAndTimeFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
