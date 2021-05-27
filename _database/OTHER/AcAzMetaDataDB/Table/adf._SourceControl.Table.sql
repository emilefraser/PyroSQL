SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[_SourceControl]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[_SourceControl](
	[SourceControlId] [int] IDENTITY(0,1) NOT NULL,
	[CreatedDT]  AS (getdate()),
 CONSTRAINT [PK_SourceControlID] PRIMARY KEY CLUSTERED 
(
	[SourceControlId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
