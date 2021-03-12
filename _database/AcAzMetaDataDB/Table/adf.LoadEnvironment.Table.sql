SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadEnvironment]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadEnvironment](
	[LoadEnvironmentID] [int] IDENTITY(0,1) NOT NULL,
	[LoadEnvironmentCode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadEnvironmentName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsPrependLoadEnvironmentCode] [bit] NOT NULL,
	[IsAppendLoadEnvironmentCode] [bit] NOT NULL,
	[CreateDT] [datetime] NOT NULL,
 CONSTRAINT [PK_adf.LoadEnvironment] PRIMARY KEY CLUSTERED 
(
	[LoadEnvironmentID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
