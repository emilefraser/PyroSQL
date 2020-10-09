SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_config_store_internal](
	[parameter_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parameter_value] [sql_variant] NULL
) ON [PRIMARY]

GO
