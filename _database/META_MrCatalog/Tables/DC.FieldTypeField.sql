SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[FieldTypeField](
	[FieldTypeFieldID] [int] IDENTITY(1,1) NOT NULL,
	[FieldID] [int] NULL,
	[FieldTypeID] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
