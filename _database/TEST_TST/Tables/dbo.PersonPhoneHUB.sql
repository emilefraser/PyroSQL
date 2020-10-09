SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PersonPhoneHUB](
	[PersonPhoneVID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonID] [bigint] NOT NULL,
	[PhoneNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PhoneNumberTypeID] [bigint] NOT NULL
) ON [PRIMARY]

GO
