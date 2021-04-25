SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmailAddressSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmailAddressSAT](
	[EmailAddressVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EmailAddress] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmailAddressVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__703483B9]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressSAT]'))
ALTER TABLE [datavault].[EmailAddressSAT]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__795EC697]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressSAT]'))
ALTER TABLE [datavault].[EmailAddressSAT]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__7BC631F6]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressSAT]'))
ALTER TABLE [datavault].[EmailAddressSAT]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
