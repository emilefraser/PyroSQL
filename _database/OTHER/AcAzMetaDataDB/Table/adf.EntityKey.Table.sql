SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[EntityKey]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[EntityKey](
	[EntityKeyID] [int] IDENTITY(0,1) NOT NULL,
	[EntityKeyCode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityKeyDefinition] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityKeyTypeID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_adf.EntityKey] PRIMARY KEY CLUSTERED 
(
	[EntityKeyID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
