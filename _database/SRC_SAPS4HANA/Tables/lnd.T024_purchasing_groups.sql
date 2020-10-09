SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[T024_purchasing_groups](
	[MANDT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EKGRP] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EKNAM] [nvarchar](18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EKTEL] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LDEST] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TELFX] [nvarchar](31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TEL_NUMBER] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TEL_EXTENS] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMTP_ADDR] [nvarchar](241) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
