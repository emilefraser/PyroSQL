SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE azure.CreateAndPopulateArmTemplate
AS
BEGIN

	DROP TABLE IF EXISTS [azure].[ArmTemplate]

	CREATE TABLE [azure].[ArmTemplate](
		[ArmTemplateID] [int] IDENTITY(0,1) NOT NULL,
		[ElementName] nvarchar(128) NOT NULL,
		[ElementRequired] BIT NOT NULL DEFAULT 1,
		[ElementDescription] [nvarchar](max) NULL,
		[ElementOrder] SMALLINT NULL,
		[CreatedDT] [datetime2](7) NULL,
	 CONSTRAINT [PK_ArmTemplate] PRIMARY KEY CLUSTERED 
	(
		[ArmTemplateID] ASC
	)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	GO

	ALTER TABLE [azure].[ArmTemplate] ADD  CONSTRAINT [DF_ArmTemplate_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
	GO

END
