SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DATES](
	[DateID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Day] [int] NOT NULL,
	[QuarterNumber] [int] NOT NULL
) ON [PRIMARY]

GO
