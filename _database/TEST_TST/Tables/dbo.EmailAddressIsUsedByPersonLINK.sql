SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmailAddressIsUsedByPersonLINK](
	[EmailAddressIsUsedByPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmailAddressVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
