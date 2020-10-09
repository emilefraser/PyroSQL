SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[Sprint](
	[SprintID] [int] NOT NULL,
	[SprintNumber] [int] NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
