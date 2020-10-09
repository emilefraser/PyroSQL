SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PersonSAT](
	[PersonVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[NameStyle] [bit] NULL,
	[EmailPromotion] [tinyint] NOT NULL,
	[FirstName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LastName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PersonTypeCode] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AdditionalContactInfo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Demographics] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MiddleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PasswordHash] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PasswordSalt] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Suffix] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
