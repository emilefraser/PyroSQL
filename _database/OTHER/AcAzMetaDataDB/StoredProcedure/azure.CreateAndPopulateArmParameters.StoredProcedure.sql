SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[CreateAndPopulateArmParameters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [azure].[CreateAndPopulateArmParameters] AS' 
END
GO

/*
	EXEC azure.CreateAndPopulateArmParameter
	SELECT * FROM [azure].[ArmParameter]
*/
ALTER   PROCEDURE [azure].[CreateAndPopulateArmParameters]
AS
BEGIN

	DROP TABLE IF EXISTS [azure].[ArmParameter]

	CREATE TABLE [azure].[ArmParameter] (
		[ArmParameterID]					INT IDENTITY(1,1) NOT NULL,
		[ParameterName]					NVARCHAR(128) NOT NULL,
		[DefaultValue]					NVARCHAR(100) NULL,
		[SqlServerParameter]				NVARCHAR(128) NULL,
		[SqlServerConversionDefinition]	NVARCHAR(MAX) NULL,
		[CreatedDT]						DATETIME2(7) CONSTRAINT [DF_ArmParameter_CreatedDT]  DEFAULT (GETDATE()) NOT NULL,
	 CONSTRAINT [PK_ArmParameter] PRIMARY KEY CLUSTERED (
		[ArmParameterID] ASC
		)
	) ON [PRIMARY]
	
	

	INSERT INTO [azure].[ArmParameter] (
		[ParameterName],
		[DefaultValue],
		[SqlServerParameter],
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
