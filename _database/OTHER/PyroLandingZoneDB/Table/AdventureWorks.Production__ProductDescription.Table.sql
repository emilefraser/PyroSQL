SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Production__ProductDescription]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Production__ProductDescription](
	[ProductDescriptionID] [int] NOT NULL,
	[Description] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
