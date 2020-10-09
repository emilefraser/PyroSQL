SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[Recipients](
	[RecipientId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailAddress] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MessagePreference] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Enabled] [bit] NOT NULL
) ON [PRIMARY]

GO
