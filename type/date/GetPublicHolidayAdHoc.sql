USE [MsMaster]
GO

/****** Object:  Table [dbo].[SchoolHolidays]    Script Date: 2020-06-30 08:12:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PublicHolidays_AdHoc](
	[HolidayID] [int] IDENTITY(1,1) NOT NULL,
	[HolidayName] [varchar](30) NULL,
	[HolidayDate] [date] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PublicHolidays_AdHoc] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO

ALTER TABLE [dbo].[PublicHolidays_AdHoc] ADD  DEFAULT ((1)) FOR [IsActive]
GO


