SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[Password](
	[BusinessEntityID] [int] NOT NULL,
	[PasswordHash] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PasswordSalt] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
