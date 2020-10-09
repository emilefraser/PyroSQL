SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [config].[Generic](
	[ConfigID] [int] IDENTITY(1,1) NOT NULL,
	[ConfigCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ConfigDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValue] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValueType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [config].[GenericHistory] )
)

GO
