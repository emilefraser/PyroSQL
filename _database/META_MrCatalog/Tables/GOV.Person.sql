SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[Person](
	[PersonID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Surname] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DomainAccountName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Email] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MobileNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WorkNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Department] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SubDepartment] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Team] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsIntegratedRecord] [bit] NULL,
	[PersonUniqueKey] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TimeZone] [char](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
