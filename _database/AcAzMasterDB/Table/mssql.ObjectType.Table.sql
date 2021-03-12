SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[ObjectType]') AND type in (N'U'))
BEGIN
CREATE TABLE [mssql].[ObjectType](
	[ObjectTypeCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectTypeName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectTypeDescription] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ObjectTypeCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[DF_mssql_ObjectType_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [mssql].[ObjectType] ADD  CONSTRAINT [DF_mssql_ObjectType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
