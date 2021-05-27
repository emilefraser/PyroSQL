SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Version]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Version](
	[major_version] [int] NOT NULL,
	[minor_version] [int] NOT NULL,
	[build] [int] NOT NULL,
	[build_dt] [datetime] NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED 
(
	[major_version] ASC,
	[minor_version] ASC,
	[build] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
