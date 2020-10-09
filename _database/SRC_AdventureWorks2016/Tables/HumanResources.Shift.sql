SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[Shift](
	[ShiftID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
