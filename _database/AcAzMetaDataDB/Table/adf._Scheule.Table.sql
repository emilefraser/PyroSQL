SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[_Scheule]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[_Scheule](
	[ScheuleId] [int] IDENTITY(0,1) NOT NULL,
	[CreatedDT]  AS (getdate()),
 CONSTRAINT [PK_ScheuleID] PRIMARY KEY CLUSTERED 
(
	[ScheuleId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
