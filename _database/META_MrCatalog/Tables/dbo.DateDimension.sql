SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DateDimension](
	[CalendarDate] [date] NOT NULL,
	[CalendarDT]  AS (CONVERT([datetime2](7),[CalendarDate])),
	[CalendarDateNumber]  AS (CONVERT([int],format([CalendarDate],'yyyyMMdd')))
) ON [PRIMARY]

GO
