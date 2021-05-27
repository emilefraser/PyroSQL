SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[schema_info_dss]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataSync].[schema_info_dss](
	[schema_major_version] [int] NOT NULL,
	[schema_minor_version] [int] NOT NULL,
	[schema_extended_info] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_DataSync.schema_info_dss] PRIMARY KEY CLUSTERED 
(
	[schema_major_version] ASC,
	[schema_minor_version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
