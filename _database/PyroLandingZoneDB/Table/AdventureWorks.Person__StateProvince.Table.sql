SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Person__StateProvince]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Person__StateProvince](
	[StateProvinceID] [int] NOT NULL,
	[StateProvinceCode] [nchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CountryRegionCode] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsOnlyStateProvinceFlag] [dbo].[Flag] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
