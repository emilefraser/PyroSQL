SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_DataDefinition]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_DataDefinition](
	[DefinitionId] [int] IDENTITY(0,1) NOT NULL,
	[DefinitionCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefinitionName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionType] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefinitionClass] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionClassSub] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionTSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DefinitionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [construct].[Language_DataDefinition_History] )
)
END
GO
