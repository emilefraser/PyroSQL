SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DimEmployeePosition](
	[EmployeePositionKey] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PositionCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PositionDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PositionShortDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentEmployeePositionKey] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CompanyCode] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
