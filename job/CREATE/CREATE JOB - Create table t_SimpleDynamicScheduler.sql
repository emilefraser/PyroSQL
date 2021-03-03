CREATE TABLE [dbo].[t_SimpleDynamicScheduler](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Type] [char](1) NOT NULL,
	[Frequency] [char](1) NULL,
	[RecurseEvery] [tinyint] NULL,
	[DaysOfWeek] [varchar](20) NULL,
	[MonthlyOccurrence] [char](1) NULL,
	[ExactDateOfMonth] [tinyint] NULL,
	[ExactWeekdayOfMonth] [char](2) NULL,
	[ExactWeekdayOfMonthEvery] [tinyint] NULL,
	[DailyFrequency] [char](1) NULL,
	[TimeStart] [time](0) NOT NULL,
	[OccursEveryValue] [tinyint] NULL,
	[OccursEveryTimeUnit] [char](1) NULL,
	[TimeEnd] [time](0) NULL,
	[ValidDays] [varchar](20) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [PK_SimpleDynamicScheduler] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'O=One Time, R=Recurring' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'D=Daily, W=Weekly, M=Monthly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'Frequency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applies only for ScheduleFrequency=W. 2 letter day of week with any separator. Example: ''Mo-We_Fr'', ''Sa Su We''' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'DaysOfWeek'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Specific for monthly schedule. D=on the day of the month, W=On the weekday of the month' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'MonthlyOccurrence'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monthly occurrence will run on this specific day. For example, if value is 15, schedule will run on each 15th day of month' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'ExactDateOfMonth'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'O=Once, E=Every' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'DailyFrequency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Time when daily frequency starts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'TimeStart'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applies if daily frequency is set to E. Time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'OccursEveryValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applies if daily frequency is set to E. H=Hour, M=Minute, S=Second' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'OccursEveryTimeUnit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applies if daily frequency is set to E. Time when daily frequency ends. Can be null which means it is open ended.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'TimeEnd'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Global. Time when scheduler starts being active.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'StartDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Global. Time when scheduler expires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'EndDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Global. If Enabled=false it won''t work. Simple.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N't_SimpleDynamicScheduler', @level2type=N'COLUMN',@level2name=N'Enabled'
GO


