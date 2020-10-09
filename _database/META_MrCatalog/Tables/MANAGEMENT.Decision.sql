SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MANAGEMENT].[Decision](
	[DecisionID] [int] IDENTITY(1,1) NOT NULL,
	[DecisionArea] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DecisionName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DecisionDescription] [varbinary](1000) NULL
) ON [PRIMARY]

GO
