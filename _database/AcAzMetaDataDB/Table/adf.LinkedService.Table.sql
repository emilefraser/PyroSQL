SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LinkedService]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LinkedService](
	[LinkedServiceId] [int] IDENTITY(0,1) NOT NULL,
	[LinkedServiceGUID] [uniqueidentifier] NULL,
	[LinkedServiceName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LinkedSericeDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataFactoryID] [int] NULL,
	[CreatedDT]  AS (getdate()),
 CONSTRAINT [PK_LinkedServiceID] PRIMARY KEY CLUSTERED 
(
	[LinkedServiceId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
