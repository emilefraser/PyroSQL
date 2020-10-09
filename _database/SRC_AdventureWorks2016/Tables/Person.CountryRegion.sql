SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[CountryRegion](
	[CountryRegionCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
