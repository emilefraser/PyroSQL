SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dba_missingIndexStoredProc]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[dba_missingIndexStoredProc](
	[missingIndexSP_id] [int] IDENTITY(1,1) NOT NULL,
	[databaseName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[databaseID] [int] NOT NULL,
	[objectName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[objectID] [int] NOT NULL,
	[query_plan] [xml] NOT NULL,
	[executionDate] [smalldatetime] NOT NULL,
	[statementExecutions] [int] NOT NULL,
 CONSTRAINT [PK_missingIndexStoredProc] PRIMARY KEY CLUSTERED 
(
	[missingIndexSP_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
