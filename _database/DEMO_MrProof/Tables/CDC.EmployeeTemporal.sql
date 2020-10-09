SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CDC].[EmployeeTemporal](
	[empid] [int] IDENTITY(1,1) NOT NULL,
	[lastname] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[firstname] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[hiredate] [date] NOT NULL,
	[terminationdate] [date] NULL,
	[city] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mgrid] [int] NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [CDC].[EmployeeTemporalHistory] )
)

GO
