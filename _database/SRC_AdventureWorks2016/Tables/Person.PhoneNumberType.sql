SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[PhoneNumberType](
	[PhoneNumberTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
