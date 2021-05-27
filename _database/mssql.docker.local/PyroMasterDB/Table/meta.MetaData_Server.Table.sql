SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[MetaData_Server]') AND type in (N'U'))
BEGIN
CREATE TABLE [meta].[MetaData_Server](
	[ServerId] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerUniqueAddress] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[DF__MetaData___Creat__09EA341B]') AND type = 'D')
BEGIN
ALTER TABLE [meta].[MetaData_Server] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
