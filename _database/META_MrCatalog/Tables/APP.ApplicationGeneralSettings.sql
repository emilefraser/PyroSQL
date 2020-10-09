SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[ApplicationGeneralSettings](
	[AppGenSettingID] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsHeaderItem] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[SortOrder] [int] NULL
) ON [PRIMARY]

GO
