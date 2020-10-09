SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[Addedfeatures](
	[AddedfeatureID] [int] IDENTITY(1,1) NOT NULL,
	[FeaturesDescription] [varchar](225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[VersionID] [int] NULL
) ON [PRIMARY]

GO
