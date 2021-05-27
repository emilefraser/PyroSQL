SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Person__Person]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Person__Person](
	[BusinessEntityID] [int] NOT NULL,
	[PersonType] [nchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NameStyle] [dbo].[NameStyle] NOT NULL,
	[Title] [nvarchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[Suffix] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailPromotion] [int] NOT NULL,
	[AdditionalContactInfo] [xml] NULL,
	[Demographics] [xml] NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
