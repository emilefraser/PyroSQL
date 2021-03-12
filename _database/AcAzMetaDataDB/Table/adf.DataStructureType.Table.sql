SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[DataStructureType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[DataStructureType](
	[DataStructureTypeID] [int] IDENTITY(0,1) NOT NULL,
	[DataStructureCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataStructureName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_DataStructureType] PRIMARY KEY CLUSTERED 
(
	[DataStructureTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
