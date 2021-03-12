SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[Culture]') AND type in (N'U'))
BEGIN
CREATE TABLE [dim].[Culture](
	[CultureID] [int] IDENTITY(0,1) NOT NULL,
	[CultureCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CultureName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[IsMssqlAllowed] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CultureID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF_dim_Culture_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[Culture] ADD  CONSTRAINT [DF_dim_Culture_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF_dim_Culture_IsMssqlAllowed]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[Culture] ADD  CONSTRAINT [DF_dim_Culture_IsMssqlAllowed]  DEFAULT ((0)) FOR [IsMssqlAllowed]
END
GO
