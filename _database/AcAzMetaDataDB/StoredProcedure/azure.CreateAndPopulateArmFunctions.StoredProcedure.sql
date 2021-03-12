SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[CreateAndPopulateArmFunctions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [azure].[CreateAndPopulateArmFunctions] AS' 
END
GO

/*
	EXEC azure.CreateAndPopulateArmFunctions
	SELECT * FROM [azure].[ArmFunctions]
*/
ALTER   PROCEDURE [azure].[CreateAndPopulateArmFunctions]
AS
BEGIN

	DROP TABLE IF EXISTS [azure].[ArmFunctions]

	CREATE TABLE [azure].[ArmFunctions] (
		[ArmFunctionsID]					INT IDENTITY(1,1) NOT NULL,
		[FunctionsName]					NVARCHAR(128) NOT NULL,
		[DefaultValue]					NVARCHAR(100) NULL,
		[SqlServerFunctions]				NVARCHAR(128) NULL,
		[SqlServerConversionDefinition]	NVARCHAR(MAX) NULL,
		[CreatedDT]						DATETIME2(7) CONSTRAINT [DF_ArmFunctions_CreatedDT]  DEFAULT (GETDATE()) NOT NULL,
	 CONSTRAINT [PK_ArmFunctions] PRIMARY KEY CLUSTERED (
		[ArmFunctionsID] ASC
		)
	) ON [PRIMARY]
	
	

	INSERT INTO [azure].[ArmFunctions] (
		[FunctionsName],
		[DefaultValue],
		[SqlServerFunctions],
		[SqlServerConversionDefinition]
	)
	VALUES 
	('string'			, 'option 1'				, 'NVARCHAR(MAX)'			, 'TRY_CONVERT(NVARCHAR(MAX), {{$1}})'),
	('securestring'		, NULL						, 'NVARCHAR(MAX)'			, 'TRY_CONVERT(NVARCHAR(MAX), {{$1}})'),
	('int'				, '1'						, 'INT'						, 'TRY_CONVERT(INT, {{$1}})'),
	('bool'				, 'true'					, 'BIT'						, 'TRY_CONVERT(BIT, IIF({{$1}}=''true'',1,0))'),
	('object'			, '{"one": "a",two": "b"}'	, 'NVARCHAR(MAX) AS JSON'	, 'TRY_CONVERT(NVARCHAR(MAX), {{$1}}) AS JSON'),
	('secureObject'		, '{}'						, 'NVARCHAR(MAX) AS JSON'	, 'TRY_CONVERT(NVARCHAR(MAX), {{$1}}) AS JSON'),
	('array'			, '[ 1, 2, 3 ]'				, 'NVARCHAR(MAX)'			, 'TRY_CONVERT(NVARCHAR(MAX), {{$1}})')


END
GO
