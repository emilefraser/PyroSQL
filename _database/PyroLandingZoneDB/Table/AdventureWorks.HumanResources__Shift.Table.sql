SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[HumanResources__Shift]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[HumanResources__Shift](
	[ShiftID] [tinyint] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
