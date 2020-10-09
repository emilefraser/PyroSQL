SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadTypeParameter](
	[LoadTypeParameterID] [int] IDENTITY(1,1) NOT NULL,
	[ParameterDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterSearchValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterValueReplacementSQLCode] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsStaticReplacementValue] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
