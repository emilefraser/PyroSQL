SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BusinessRuleKpi](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Identity]  AS (@@identity),
	[TestColumn_Insert] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestColumn_Update] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT]  AS (case when @@identity=[ID] then NULL else getdate() end),
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
