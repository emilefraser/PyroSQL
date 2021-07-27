SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[TestSession]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[TestSession](
	[TestSessionId] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestSessionStart] [datetime] NOT NULL,
	[TestSessionFinish] [datetime] NULL,
 CONSTRAINT [PK_TestSession] PRIMARY KEY CLUSTERED 
(
	[TestSessionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO