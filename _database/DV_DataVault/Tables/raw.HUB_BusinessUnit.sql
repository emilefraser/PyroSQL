SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [raw].[HUB_BusinessUnit](
	[HK_BUSINESSUNIT] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [datetime2](7) NULL,
	[RecSrcDataEntityID] [int] NULL,
	[BusinessUnitName] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Subsidiary] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastSeenDT] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
