SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[HubBusinessKeyField](
	[HubBusinessKeyFieldID] [int] IDENTITY(1,1) NOT NULL,
	[HubBusinessKeyID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[IsBaseEntityField] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
