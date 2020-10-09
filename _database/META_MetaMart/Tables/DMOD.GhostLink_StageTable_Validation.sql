SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[GhostLink_StageTable_Validation](
	[ForeignDataEntity] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ForeignField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryDataEntity] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TotalJoins] [int] NULL
) ON [PRIMARY]

GO
