/****** Object:  StoredProcedure [dbo].[CreateSchemaIfNotExists]    Script Date: 2021-01-04 22:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Gets the Azure data Factory Metadata

-- TODO			:	setup temporal tables to house the ADF Metadata
/*
	DECLARE @CustomerName NVARCHAR(MAX) = 'Saec'

	EXEC  [saec].[SetAzureDataFactoryData]
					@CustomerName = @CustomerName
*/

CREATE OR ALTER   PROCEDURE [saec].[SetAzureDataFactoryData]
	@CustomerName NVARCHAR(MAX)
AS
BEGIN

	-- Time and version control variables
	DECLARE 
		@DateTime						DATETIME2(7) = GETDATE()

	-- Constants used in the retrieval of the Arm Template
	--DECLARE 
	--	@ArmFilePath	NVARCHAR(MAX)	= 'arm/arm_template.json'
	--,	@BulkType		NVARCHAR(12)	= 'SINGLE_CLOB'

	-- Variable used to assign the Arm Json Clob value 
	DECLARE 
		@ArmJsonValue					NVARCHAR(MAX)
	,	@AzureDataFactoryName			NVARCHAR(MAX)

	-- Gets the Dataset value of the CLOB value via OpenRowSet
	--EXEC [inout].[GetExternalDataSetWithOpenRowset]
	--					@ExternalFolderName				= @CustomerName
	--				,	@ExternalRelativeFilePath		= @ArmFilePath
	--				,	@BulkType						= @BulkType
	--				,	@ExternalDataSetValue			= @ArmJsonValue OUTPUT

	
	-- build temp table
	--CREATE TABLE ##tempy (JsonValue NVARCHAR(MAX)) 
	--INSERT INTO ##tempy
	--SELECT @ArmJsonValue
	
	SELECT 
		@ArmJsonValue = JsonValue
	FROM 
		##tempy

	SELECT 
		*
	FROM 
		OPENJSON(@ArmJsonValue)


	SELECT
		*
	FROM 
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[resources] NVARCHAR(MAX) AS JSON
		) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (
			ResourceArray.[resources]
		) AS ResourceDetails
		
		/*
		WITH (
			[name]					NVARCHAR(MAX) 
		,	[type]					NVARCHAR(500)
		,	[apiVersion]			DATE
		,	[properties]			NVARCHAR(MAX) AS JSON
		) AS ResourceDetails

		--linked service details
		CROSS APPLY OPENJSON (
			ResourceDetails.[properties]
		) 
		--WITH (
		--	[type]					NVARCHAR(MAX)
		--,	[description]			NVARCHAR(MAX)
		--) AS Properties
		*/
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/linkedServices'



	-- Gets the DataFactory Name
	SELECT
		@AzureDataFactoryName = factory.[defaultValue]
	FROM 
		OPENJSON(@ArmJsonValue) WITH (
			[parameters] NVARCHAR(MAX) AS JSON
		) AS params
		CROSS APPLY OPENJSON (
			params.[parameters]
		) 
		WITH (
			[factoryName] NVARCHAR(MAX) AS JSON
		) AS detail
		CROSS APPLY OPENJSON (
			detail.[factoryName]
		) WITH (
			[defaultValue]	NVARCHAR(128)
		) AS factory



	/* ------------------------------------------------------------
							Full JSON String
	------------------------------------------------------------ */
	SELECT 
		JsonValue					= @ArmJsonValue
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName


	/* ------------------------------------------------------------
							Schema Template Url
	------------------------------------------------------------ */
	SELECT
		SchemaUrl					= factory.[$schema]
	,	ContentVersion				= factory.[contentVersion]
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName
	FROM 
		OPENJSON(@ArmJsonValue) -- Top Level Template
	WITH (
		[$schema]			NVARCHAR(128)
	,	[contentVersion]	NVARCHAR(128)
	) AS factory


	/* ------------------------------------------------------------
							Data Factory Name
	------------------------------------------------------------ */
	SELECT
		DataFactory					= factory.[defaultValue]
	,	DataType					= factory.[type]
	,	MetaData					= factory.[metadata]
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH (
			[parameters] NVARCHAR(MAX) AS JSON
		) AS params
		CROSS APPLY OPENJSON (
			params.[parameters]
		) WITH (
			[factoryName] NVARCHAR(MAX) AS JSON
		) AS detail
		CROSS APPLY OPENJSON (
			detail.[factoryName]
		) WITH (
			[type]			NVARCHAR(128),
			[metadata]		NVARCHAR(128),
			[defaultValue]	NVARCHAR(128)
		) AS factory



	/* ------------------------------------------------------------
							component summary
	------------------------------------------------------------ */
	SELECT 
		ComponentType				= CONVERT(NVARCHAR(50), 'DataFactories' )
	,	ComponentCount				= CONVERT(INT, 1)	
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName

	UNION 

	SELECT
		ComponentType				= UPPER(LEFT(REPLACE(ResourceDetails.[type],'Microsoft.DataFactory/factories/',''),1)) +
										RIGHT(REPLACE(ResourceDetails.[type],'Microsoft.DataFactory/factories/',''),
											LEN(REPLACE(ResourceDetails.[type],'Microsoft.DataFactory/factories/',''))-1)
	,	ComponentCount				= COUNT(1)
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName
	FROM 
		
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[resources] NVARCHAR(MAX) AS JSON
		) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (
			ResourceArray.[resources]
		) WITH (
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
		) AS ResourceDetails
	GROUP BY
		ResourceDetails.[type]

	UNION 
	
	SELECT 
		ComponentType				= 'Activities'
	,	ComponentCount				= COUNT(ActivityDetails.[name])
	,	CustomerName				= @CustomerName
	,	AzureDataFactoryName		= @AzureDataFactoryName
	FROM 
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[resources]			NVARCHAR(MAX) AS JSON
		) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (
			ResourceArray.[resources]
		) WITH (
			[name]				NVARCHAR(MAX), 
			[type]				NVARCHAR(500),
			[apiVersion]		DATE,
			[properties]		NVARCHAR(MAX) AS JSON
		) AS ResourceDetails
	
		--pipeline details
		CROSS APPLY OPENJSON (
			ResourceDetails.[properties]
		) WITH (
			[activities]		NVARCHAR(MAX) AS JSON,
			[description]		NVARCHAR(MAX)
		) AS Properties
	
		--activity details for count
		CROSS APPLY OPENJSON (
			Properties.[activities]
		) WITH (
			[name]				NVARCHAR(MAX)
		) AS ActivityDetails	
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/pipelines'	
		

	/* ------------------------------------------------------------
							Parameters
	------------------------------------------------------------ */	
	SELECT
		ParameterJson			= ParameterJson.[value]
	,	ParameterName			= ParameterJson.[key]
	,	ParameterType			= ParameterValue.[type]
	,	ParameterMetaData		= ParameterValue.[metadata]	
	,	ParameterDefaultValue	= ParameterValue.[defaultValue]
	FROM 
		
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[parameters]		 NVARCHAR(MAX) AS JSON
		) AS ParameterArray

		CROSS APPLY OPENJSON (ParameterArray.[parameters]
		--) WITH (
		--	[value]				 NVARCHAR(MAX) AS JSON	
		) AS ParameterJson

		CROSS APPLY OPENJSON (ParameterJson.[value]
		) WITH (
			[type]				NVARCHAR(MAX)
		,	[metadata]			NVARCHAR(MAX)
		,	[defaultValue]		NVARCHAR(MAX)
		) AS ParameterValue

	/* ------------------------------------------------------------
							Variables
	------------------------------------------------------------ */
	SELECT 
			VariableJson	= [VariableArray].variables
		,	VariableName	= [VariableValue].[key]
		,	VariableValue	= [VariableValue].[value]
		FROM 
		
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[variables]		 NVARCHAR(MAX) AS JSON
		) AS VariableArray

		CROSS APPLY OPENJSON (VariableArray.[variables]) AS VariableValue

	/* ------------------------------------------------------------
							Linked Service Information
	------------------------------------------------------------ */
	SELECT
		LinkedServiceName			=	REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','')
	,	LinkedServiceType			=	Properties.[type]
	,	LinkedServiceApiVersion		=	ResourceDetails.[apiVersion] 
	,	UsingKeyVault				=	CASE
											WHEN ResourceDetails.[properties] LIKE '%AzureKeyVaultSecret%' 
												THEN 'Yes'
												ELSE 'No'
											END
	,	LinkedServiceDescription	=	Properties.[description]
	FROM 
		OPENJSON(
			@ArmJsonValue
		) WITH (
			[resources] NVARCHAR(MAX) AS JSON
		) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (
			ResourceArray.[resources]
		) WITH (
			[name]					NVARCHAR(MAX) 
		,	[type]					NVARCHAR(500)
		,	[apiVersion]			DATE
		,	[properties]			NVARCHAR(MAX) AS JSON
		) AS ResourceDetails

		--linked service details
		CROSS APPLY OPENJSON (
			ResourceDetails.[properties]
		) WITH (
			[type]					NVARCHAR(MAX)
		,	[description]			NVARCHAR(MAX)
		) AS Properties
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/linkedServices'



		/* ------------------------------------------------------------
							Depends on
	------------------------------------------------------------ */

	/*
	/* ------------------------------------------------------------
							pipeline information
	------------------------------------------------------------ */
	SELECT 
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'PipelineName',
		Properties.[description] AS 'Description',
		Folder.[name] AS 'FolderName',
		COUNT(ActivityDetails.[name]) AS 'ActivityCount'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails
	
		--pipeline details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[activities] NVARCHAR(MAX) AS JSON,
			[description] NVARCHAR(MAX),
			[folder] NVARCHAR(MAX) AS JSON
			) AS Properties
	
		--folder details
		CROSS APPLY OPENJSON (Properties.[folder]) WITH
			(
			[name] NVARCHAR(500)
			) AS Folder

		--activity details for count
		CROSS APPLY OPENJSON (Properties.[activities]) WITH
			(
			[name] NVARCHAR(MAX)
			) AS ActivityDetails
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/pipelines'			
	GROUP BY
		ResourceDetails.[name],
		Properties.[description],
		Folder.[name]


	/* ------------------------------------------------------------
							activity information
	------------------------------------------------------------ */
	SELECT 
		ActivityDetails.[name] AS 'ActivityName',
		ActivityDetails.[type] AS 'Type',
		ActivityDetails.[description] AS 'Description',
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'BelongsToPipeline'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails
	
		--pipeline details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[activities] NVARCHAR(MAX) AS JSON,
			[description] NVARCHAR(MAX)
			) AS Properties
	
		--activity details
		CROSS APPLY OPENJSON (Properties.[activities]) WITH
			(
			[name] NVARCHAR(MAX),
			[description] NVARCHAR(MAX),
			[type] NVARCHAR(500)
			) AS ActivityDetails	
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/pipelines'


	



	/* ------------------------------------------------------------
							dataset information
	------------------------------------------------------------ */
	SELECT 
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'DatasetName',
		Properties.[type] AS 'Type',
		Folder.[name] AS 'FolderName',
		RelatedLinkedService.[referenceName] AS 'ConnectedToLinkedService'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails

		--dataset details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[linkedServiceName] NVARCHAR(MAX) AS JSON,
			[type] NVARCHAR(MAX),
			[folder] NVARCHAR(MAX) AS JSON
			) AS Properties

		--folder details
		CROSS APPLY OPENJSON (Properties.[folder]) WITH
			(
			[name] NVARCHAR(500)
			) AS Folder
		
		--linked service connection
		CROSS APPLY OPENJSON (Properties.[linkedServiceName]) WITH
			(
			[referenceName] NVARCHAR(500)
			) AS RelatedLinkedService
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/datasets'


	/* ------------------------------------------------------------
					integration runtime information
	------------------------------------------------------------ */
	SELECT 
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'IntegrationRuntimeName',
		Properties.[type] AS 'Type'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails

		--ir details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[type] NVARCHAR(500)
			) AS Properties
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/integrationRuntimes'


	/* ------------------------------------------------------------
							dataflow information
	------------------------------------------------------------ */
	SELECT 
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'DataFlowName',
		Properties.[type] AS 'Type'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails

		--df details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[type] NVARCHAR(500)
			) AS Properties
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/dataflows'


	/* ------------------------------------------------------------
							trigger information
	------------------------------------------------------------ */
	SELECT 
		REPLACE(SUBSTRING(ResourceDetails.[name], CHARINDEX('/',ResourceDetails.[name])+1, 50),''')]','') AS 'TriggerName',
		Properties.[type] AS 'Type',
		Properties.[runtimeState] AS 'Status'
	FROM 
		--top level template
		OPENJSON(@ArmJsonValue) WITH 
			(
			[resources] NVARCHAR(MAX) AS JSON
			) AS ResourceArray
	
		--resource details
		CROSS APPLY OPENJSON (ResourceArray.[resources]) WITH 
			(
			[name] NVARCHAR(MAX), 
			[type] NVARCHAR(500),
			[apiVersion] DATE,
			[properties] NVARCHAR(MAX) AS JSON
			) AS ResourceDetails

		--trigger details
		CROSS APPLY OPENJSON (ResourceDetails.[properties]) WITH
			(
			[runtimeState] NVARCHAR(500),
			[type] NVARCHAR(500)
			) AS Properties
	WHERE
		ResourceDetails.[type] = 'Microsoft.DataFactory/factories/triggers'
		*/
	
END