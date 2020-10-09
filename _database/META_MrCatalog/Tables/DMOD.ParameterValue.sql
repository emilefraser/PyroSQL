SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[ParameterValue](
	[ParameterValueID] [int] IDENTITY(1,1) NOT NULL,
	[ParameterID] [int] NOT NULL,
	[ValueDecimal] [decimal](28, 4) NULL,
	[ValueInt] [int] NULL,
	[ValueDate] [datetime2](0) NULL,
	[ValueVarchar] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ClosedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
