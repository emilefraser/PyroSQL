SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Numbers]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Numbers](
	[n] [bigint] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[adf].[Numbers]') AND name = N'ucix_Numbers_n')
CREATE UNIQUE CLUSTERED INDEX [ucix_Numbers_n] ON [adf].[Numbers]
(
	[n] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
