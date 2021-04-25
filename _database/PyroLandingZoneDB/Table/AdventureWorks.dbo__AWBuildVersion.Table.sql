SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[dbo__AWBuildVersion]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[dbo__AWBuildVersion](
	[SystemInformationID] [tinyint] NOT NULL,
	[Database Version] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VersionDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
