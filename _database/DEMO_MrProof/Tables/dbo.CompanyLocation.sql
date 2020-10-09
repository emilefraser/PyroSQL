SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CompanyLocation](
	[LocID] [int] IDENTITY(1,1) NOT NULL,
	[LocName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[City] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SysStartTime] [datetime2](0) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](0) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[MSSQL_TemporalHistoryFor_1938105945] )
)

GO