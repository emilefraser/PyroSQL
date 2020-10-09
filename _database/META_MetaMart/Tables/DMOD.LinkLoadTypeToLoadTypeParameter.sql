SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkLoadTypeToLoadTypeParameter](
	[LinkLoadTypeToLoadTypeParameterID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeID] [int] NOT NULL,
	[LoadTypeParameterID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
