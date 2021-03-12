SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[CreateAndPopulateArmTemplate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [azure].[CreateAndPopulateArmTemplate] AS' 
END
GO

/*
	EXEC azure.CreateAndPopulateArmTemplate
	SELECT * FROM [azure].[ArmTemplate]
*/
ALTER   PROCEDURE [azure].[CreateAndPopulateArmTemplate]
AS
BEGIN

	DROP TABLE IF EXISTS [azure].[ArmTemplate]

	CREATE TABLE [azure].[ArmTemplate](
		[ArmTemplateID]					INT IDENTITY(0,1) NOT NULL,
		[ElementName]					NVARCHAR(128) NOT NULL,
		[ElementRequired]				BIT CONSTRAINT DF_ArmTemplate_Required DEFAULT 1 NOT NULL,
		[ElementDescription]			NVARCHAR(max) NULL,
		[ElementOrder]					SMALLINT NULL,
		[CreatedDT]						DATETIME2(7) CONSTRAINT [DF_ArmTemplate_CreatedDT]  DEFAULT (GETDATE()) NOT NULL,
	 CONSTRAINT [PK_ArmTemplate] PRIMARY KEY CLUSTERED (
		[ArmTemplateID] ASC
		)
	) ON [PRIMARY]
	
	

	INSERT INTO [azure].[ArmTemplate] (
		[ElementName],
		[ElementRequired],
		[ElementDescription],
		[ElementOrder]
	)
	VALUES 
	('$schema'			, 1, 'Location of the JavaScript Object Notation (JSON) schema file that describes the version of the template language.', 1), 
	('contentVersion'	, 1, 'Version of the template (such as 1.0.0.0).', 2),
	('apiProfile'		, 0, 'An API version that serves as a collection of API versions for resource types.', 3),
	('parameters'		, 0, 'Values that are provided when deployment is executed to customize resource deployment.', 4),
	('variables'		, 0, 'Values that are used as JSON fragments in the template to simplify template language expressions.', 5),
	('functions'		, 0, 'User-defined functions that are available within the template', 6),
	('resources'		, 1, 'Resource types that are deployed or updated in a resource group or subscription.', 7),
	('outputs'			, 0, 'Values that are returned after deployment.', 8)


END
GO
