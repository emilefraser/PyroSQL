SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [config].[Company](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyLogoOLD] [varbinary](max) NULL,
	[CompanyLogo] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingCompanyLogo] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingCalendarID] [int] NOT NULL,
	[ReportingCalendarID_Master] [int] NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [config].[CompanyHistory] )
)

GO
