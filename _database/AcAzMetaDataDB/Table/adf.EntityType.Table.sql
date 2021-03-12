SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[EntityType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[EntityType](
	[EntityTypeId] [int] IDENTITY(0,1) NOT NULL,
	[EntityCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataStructureTypeId] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_EntityType] PRIMARY KEY CLUSTERED 
(
	[EntityTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
