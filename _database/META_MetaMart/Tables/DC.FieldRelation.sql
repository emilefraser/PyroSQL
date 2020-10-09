SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[FieldRelation](
	[FieldRelationID] [int] IDENTITY(1,1) NOT NULL,
	[SourceFieldID] [int] NULL,
	[TargetFieldID] [int] NULL,
	[FieldRelationTypeID] [int] NULL,
	[TransformDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
