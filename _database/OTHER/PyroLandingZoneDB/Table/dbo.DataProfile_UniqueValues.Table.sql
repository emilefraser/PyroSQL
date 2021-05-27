SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataProfile_UniqueValues]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DataProfile_UniqueValues](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnType] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnUniqueValues] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UniqueValueOccurance] [bigint] NULL,
	[MissingDataRowCount] [bigint] NULL,
	[MinValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaxValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpecialCharacters] [bigint] NULL,
	[LeadingTrailingSpaces] [bigint] NULL,
	[MinFieldValueLen] [bigint] NULL,
	[MaxFieldValueLen] [bigint] NULL,
	[UniqueValue] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
