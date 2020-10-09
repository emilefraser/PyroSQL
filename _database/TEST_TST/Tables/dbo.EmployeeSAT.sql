SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeeSAT](
	[EmployeeVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CurrentFlag] [bit] NULL,
	[SalariedFlag] [bit] NULL,
	[BirthDate] [datetime] NOT NULL,
	[Gender] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HireDate] [datetime] NOT NULL,
	[JobTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoginID] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MaritalStatus] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NationalIDNumber] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SickLeaveHours] [int] NOT NULL,
	[VacationHours] [int] NOT NULL
) ON [PRIMARY]

GO
