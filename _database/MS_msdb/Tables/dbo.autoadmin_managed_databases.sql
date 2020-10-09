SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[autoadmin_managed_databases](
	[autoadmin_id] [bigint] IDENTITY(1,1) NOT NULL,
	[db_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[db_id] [int] NOT NULL,
	[db_guid] [uniqueidentifier] NOT NULL,
	[group_db_guid] [uniqueidentifier] NULL,
	[drop_date] [datetime] NULL
) ON [PRIMARY]

GO
