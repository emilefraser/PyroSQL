SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[_Property]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[_Property](
	[PropertyID] [int] IDENTITY(0,1) NOT NULL,
 CONSTRAINT [PK_PropertyID] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO