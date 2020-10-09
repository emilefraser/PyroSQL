SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[LinkBKCombination](
	[LinkBKCombinationID] [int] IDENTITY(1,1) NOT NULL,
	[LinkID] [int] NOT NULL,
	[DataCatalogFieldID] [int] NOT NULL,
	[BusinessKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
