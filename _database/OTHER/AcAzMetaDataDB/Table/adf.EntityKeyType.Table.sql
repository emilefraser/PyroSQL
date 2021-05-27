SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[EntityKeyType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[EntityKeyType](
	[EntityKeyTypeID] [int] IDENTITY(0,1) NOT NULL,
	[EntityKeyTypeCode] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityKeyTypeName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityKeyTypeDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_adf.EntityKeyType] PRIMARY KEY CLUSTERED 
(
	[EntityKeyTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
