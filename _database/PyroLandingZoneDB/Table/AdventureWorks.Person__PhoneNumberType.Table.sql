SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Person__PhoneNumberType]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Person__PhoneNumberType](
	[PhoneNumberTypeID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
