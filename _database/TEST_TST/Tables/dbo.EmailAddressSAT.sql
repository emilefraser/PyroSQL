SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmailAddressSAT](
	[EmailAddressVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EmailAddress] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
