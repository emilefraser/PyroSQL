SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_primary_secondaries](
	[primary_id] [uniqueidentifier] NOT NULL,
	[secondary_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[secondary_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
