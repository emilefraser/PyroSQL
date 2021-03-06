/****** Object:  StoredProcedure [azure].[CreateAndPopulateArmTemplate]    Script Date: 2021-01-09 10:22:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		[ElementId]						INT IDENTITY(0,1) NOT NULL,
		[ElementName]					NVARCHAR(128) NOT NULL,
		[ElementRequired]				BIT CONSTRAINT DF_ArmTemplate_Required DEFAULT 1 NOT NULL,
		[ElementDescription]			NVARCHAR(MAX) NULL,
		[ElementDataType]				INT NOT NULL,
		[ElementId_Parent]				INT NULL,
		[ElementOrder]					DECIMAL(7,3) NULL,
		[ElementJsonString]				NVARCHAR(MAX) NULL,
		[CreatedDT]						DATETIME2(7) CONSTRAINT [DF_ArmTemplate_CreatedDT] DEFAULT (GETDATE()) NOT NULL,
	 CONSTRAINT [PK_ArmTemplate] PRIMARY KEY CLUSTERED (
		[ElementId] ASC
		)
	) ON [PRIMARY]
	
	
	/*
	ArmDataTypeID	DataTypeName
	1	string
	2	securestring
	3	int
	4	bool
	5	object
	6	secureObject
	7	array
	*/

	/*
	Objects start with a left brace ({) and end with a right brace (}). Arrays start with a left bracket ([) and end with a right bracket (]).

	However, if you set that secure value to a property that isn't expecting a secure value, the value isn't protected. For example, if you set a secure string to a tag, that value is stored as plain text. Use secure strings for passwords and secrets.

For integers passed as inline parameters, the range of values may be limited by the SDK or command-line tool you use for deployment. For example, when using PowerShell to deploy a template, integer types can range from -2147483648 to 2147483647. To avoid this limitation, specify large integer values in a parameter file. Resource types apply their own limits for integer properties.

When specifying boolean and integer values in your template, don't surround the value with quotation marks. Start and end string values with double quotation marks ("string value").

	*/
	INSERT INTO [azure].[ArmTemplate] (
		[ElementName],
		[ElementRequired],
		[ElementDescription],
		[ElementDataType],
		[ElementId_Parent],
		[ElementOrder],
		[ElementJsonString],
	)
	VALUES 
	('$schema'			, 1, 'Location of the JavaScript Object Notation (JSON) schema file that describes the version of the template language.', 1), 
	('contentVersion'	, 1, 'Version of the template (such as 1.0.0.0).', 2),
	('apiProfile'		, 0, 'An API version that serves as a collection of API versions for resource types.', 3),

	(
		'parameters'		
			, 0
			, 'Values that are provided when deployment is executed to customize resource deployment.'
			, 5
			, NULL
			, 4.001
			, '"parameters": {
				  "<parameter-name>" : {
					"type" : "<type-of-parameter-value>",
					"defaultValue": "<default-value-of-parameter>",
					"allowedValues": [ "<array-of-allowed-values>" ],
					"minValue": <minimum-value-for-int>,
					"maxValue": <maximum-value-for-int>,
					"minLength": <minimum-length-for-string-or-array>,
					"maxLength": <maximum-length-for-string-or-array-parameters>,
					"metadata": {
					  "description": "<description-of-the parameter>"
					}
				  }
				}'
	),
			
			
			
	(
		'variables'		
			, 0
			, 'Values that are used as JSON fragments in the template to simplify template language expressions.'
			, 5
			, NULL
			, 5.001
			, '"variables": {
				  "<variable-name>": "<variable-value>",
				  "<variable-name>": {
					<variable-complex-type-value>
				  },
				  "<variable-object-name>": {
					"copy": [
					  {
						"name": "<name-of-array-property>",
						"count": <number-of-iterations>,
						"input": <object-or-value-to-repeat>
					  }
					]
				  },
				  "copy": [
					{
					  "name": "<variable-array-name>",
					  "count": <number-of-iterations>,
					  "input": <object-or-value-to-repeat>
					}
				  ]
				}'
	),		
			
			
			
			
			
			),





	(''		, 0, '', 5),
	('functions'		, 0, 'User-defined functions that are available within the template', 6),
	('resources'		, 1, 'Resource types that are deployed or updated in a resource group or subscription.', 7),
	('outputs'			, 0, 'Values that are returned after deployment.', 8)





END
