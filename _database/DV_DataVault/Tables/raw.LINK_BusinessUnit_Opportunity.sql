SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [raw].[LINK_BusinessUnit_Opportunity](
	[HK_BusinessUnit_Opportunity] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [datetime2](7) NULL,
	[RecSrcDataEntityID] [int] NULL,
	[HK_Opportunity] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HK_BusinessUnit] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
