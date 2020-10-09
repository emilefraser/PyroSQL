SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[Employee](
	[BusinessEntityID] [int] NOT NULL,
	[NationalIDNumber] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoginID] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel]  AS ([OrganizationNode].[GetLevel]()),
	[JobTitle] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Gender] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] [dbo].[Flag] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
