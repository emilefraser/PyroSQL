SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PersonCreditCardLINK](
	[PersonCreditCardVID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonVID] [bigint] NOT NULL,
	[CreditCardVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
