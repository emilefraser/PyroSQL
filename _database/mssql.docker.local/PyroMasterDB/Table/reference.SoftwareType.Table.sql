SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[SoftwareType]') AND type in (N'U'))
BEGIN
CREATE TABLE [reference].[SoftwareType](
	[SoftwareTypeId] [smallint] IDENTITY(0,1) NOT NULL,
	[SoftwareTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SoftwareTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_SoftwareType] PRIMARY KEY CLUSTERED 
(
	[SoftwareTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[DF_SoftwareType_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [reference].[SoftwareType] ADD  CONSTRAINT [DF_SoftwareType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
