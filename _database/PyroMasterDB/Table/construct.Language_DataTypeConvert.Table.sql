SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_DataTypeConvert]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_DataTypeConvert](
	[DataTypeConvertId] [int] IDENTITY(0,1) NOT NULL,
	[DataTypeNameFrom] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TechnologyNameFrom] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataTypeNameTo] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TechnologyNameTo] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DataTypeConvertId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [construct].[Language_DataTypeConvert_History] )
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DF__Language___IsAct__149C0161]') AND type = 'D')
BEGIN
ALTER TABLE [construct].[Language_DataTypeConvert] ADD  DEFAULT ((1)) FOR [IsActive]
END
GO
