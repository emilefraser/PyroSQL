SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[moto_mktg].[addresses]') AND type in (N'U'))
BEGIN
CREATE TABLE [moto_mktg].[addresses](
	[address_number] [decimal](21, 6) NOT NULL,
	[street_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[street_number] [decimal](21, 6) NULL,
	[postal_code] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[city] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[province] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_user] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_timestamp] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[moto_mktg].[DF__addresses__updat__075714DC]') AND type = 'D')
BEGIN
ALTER TABLE [moto_mktg].[addresses] ADD  DEFAULT (getdate()) FOR [update_timestamp]
END
GO
