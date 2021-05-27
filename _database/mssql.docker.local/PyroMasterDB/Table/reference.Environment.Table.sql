SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[Environment]') AND type in (N'U'))
BEGIN
CREATE TABLE [reference].[Environment](
	[EnvironmentID] [int] IDENTITY(0,1) NOT NULL,
	[EnvironmentCode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EnvironmentName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsPrependLoadEnvironmentCode] [bit] NOT NULL,
	[IsAppendLoadEnvironmentCode] [bit] NOT NULL,
	[CreateDT] [datetime] NOT NULL,
 CONSTRAINT [PK_Environment] PRIMARY KEY CLUSTERED 
(
	[EnvironmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reference].[DF__Environme__Creat__1FA39FB9]') AND type = 'D')
BEGIN
ALTER TABLE [reference].[Environment] ADD  DEFAULT (getdate()) FOR [CreateDT]
END
GO
