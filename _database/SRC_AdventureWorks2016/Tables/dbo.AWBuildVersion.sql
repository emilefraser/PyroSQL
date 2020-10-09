SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AWBuildVersion](
	[SystemInformationID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Database Version] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VersionDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
