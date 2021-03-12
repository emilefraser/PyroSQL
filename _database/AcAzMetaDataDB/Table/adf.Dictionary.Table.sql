SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Dictionary]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Dictionary](
	[DictionaryID] [int] IDENTITY(0,1) NOT NULL,
	[Term] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TermDefinition] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TermSynonym] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT]  AS (getdate()),
 CONSTRAINT [PK_DictionaryID] PRIMARY KEY CLUSTERED 
(
	[DictionaryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
