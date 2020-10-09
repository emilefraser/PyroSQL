SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[Parameter](
	[ParameterID] [int] IDENTITY(1,1) NOT NULL,
	[ParameterCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValueType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
