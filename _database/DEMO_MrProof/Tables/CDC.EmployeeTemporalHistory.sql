SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CDC].[EmployeeTemporalHistory](
	[empid] [int] NOT NULL,
	[lastname] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[firstname] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[hiredate] [date] NOT NULL,
	[terminationdate] [date] NULL,
	[city] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mgrid] [int] NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)

GO
