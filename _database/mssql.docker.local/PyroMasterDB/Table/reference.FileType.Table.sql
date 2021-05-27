SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[FileType]') AND type in (N'U'))
BEGIN
CREATE TABLE [reference].[FileType](
	[FileTypeId] [smallint] IDENTITY(0,1) NOT NULL,
	[FileTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileTypeExtension] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_FileType] PRIMARY KEY CLUSTERED 
(
	[FileTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[DF_FileType_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [reference].[FileType] ADD  CONSTRAINT [DF_FileType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
