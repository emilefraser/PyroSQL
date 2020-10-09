SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SDEL].[DataSolution](
	[DataSolutionID] [int] IDENTITY(1,1) NOT NULL,
	[DataSolutionName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DeliveryStatus] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Priority] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
