SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[employee](
	[EMPNO] [int] NOT NULL,
	[ENAME] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JOB] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MGR] [int] NULL,
	[HIREDATE] [date] NULL,
	[SAL] [numeric](7, 2) NULL,
	[COMM] [numeric](7, 2) NULL,
	[DEPTNO] [int] NULL,
	[CreatedDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[UpdatedDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([CreatedDT], [UpdatedDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[MSSQL_TemporalHistoryFor_1986106116] )
)

GO
