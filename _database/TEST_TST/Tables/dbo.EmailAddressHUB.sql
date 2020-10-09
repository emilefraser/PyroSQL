SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmailAddressHUB](
	[EmailAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonID] [bigint] NOT NULL,
	[EmailAddressID] [bigint] NOT NULL
) ON [PRIMARY]

GO
