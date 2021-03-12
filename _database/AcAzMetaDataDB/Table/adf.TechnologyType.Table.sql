SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[TechnologyType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[TechnologyType](
	[TechnologyTypeId] [int] IDENTITY(0,1) NOT NULL,
	[TechnologyCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TechnologyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataStructureTypeId] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__Technolo__A244BD284D76B588] PRIMARY KEY CLUSTERED 
(
	[TechnologyTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
