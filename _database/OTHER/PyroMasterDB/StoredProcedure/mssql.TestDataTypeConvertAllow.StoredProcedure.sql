SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[TestDataTypeConvertAllow]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [mssql].[TestDataTypeConvertAllow] AS' 
END
GO

/*
	EXEC adf.TestDataTypeConvertAllow
*/	


ALTER    PROCEDURE [mssql].[TestDataTypeConvertAllow]
AS
BEGIN

	DECLARE 
	@sql_statement	NVARCHAR(MAX)
,	@sql_message	NVARCHAR(MAX)
,	@sql_parameter	NVARCHAR(MAX)
,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab		NVARCHAR(1) = CHAR(9)
,	@sql_execute	BIT = 1
,	@sql_debug		BIT = 1
,	@sql_rc			INT = 0

	DECLARE 
		@SystemName SYSNAME = 'MSSQL' 


	DECLARE @log TABLE (
		LogID				INT IDENTITY(1,1) 
	,	SourceType			VARCHAR(100)
	,	TargetType			VARCHAR(100)
	,	ConversionType		VARCHAR(10)
	,	ConversionResult	BIT
	)

	--DROP TYPE IF EXISTS adf.TestValuesTableType

	--CREATE TYPE adf.TestValuesTableType AS TABLE (
	--	TestValueID		INT IDENTITY(1,1) PRIMARY KEY
	--,	DataType		VARCHAR(50)
	--,	TestValue_Low	VARCHAR(MAX)
	--,	TestValue_High	VARCHAR(MAX)
	--)


	DECLARE  @TestValues TABLE
	(
		TestValueID		INT IDENTITY(1,1) PRIMARY KEY
	,	DataType		VARCHAR(50)
	,	TestValue_Low	VARCHAR(MAX)
	,	TestValue_High	VARCHAR(MAX)
	)

	INSERT INTO @TestValues (
		DataType
	,	TestValue_Low
	,	TestValue_High
	)
	VALUES
		('bigint', '', '9223372036854775807'),
		('binary', '', '123456'),
		('bit', '', '1'),
		('char', '', N'Some text'),
		('date', '', '9999-12-31'),
		('datetime', '', '9999-12-31 23:59:59.997'),
		('datetime2', '', '9999-12-31 23:59:59.9999999'),
		('datetimeoffset', '', '9999-12-31 23:59:59.9999999'),
		('decimal', '', '1.7915646464484'),
		('float', '', '1.7915646464484'),
		('geography', '', '0xE6100000010C61C3D32B65A14440C4B12E6EA3BD5BC0'),
		('geometry', '', CONVERT(VARCHAR, geometry::STGeomFromText('LINESTRING (0 0, 20 20, 5 5)', 0))),
		('hierarchyid', '', '/1/1/'),
		('image', '', '0x53514C20536572766572'),
		('int', '', '2147483647'),
		('money', '', '922337203685477.5807'),
		('nchar', '', N'Some text'),
		('ntext', '', N'Some text'),
		('numeric', '', '99999999.99'),
		('nvarchar', '', 'Some text'),
		('real', '', '214748.3647'),
		('smalldatetime', '', '2079-06-06 23:59:59'),
		('smallint', '', '32767'),
		('smallmoney', '', '214748.3647'),
		('sql_variant', '', CONVERT(VARCHAR, SERVERPROPERTY('edition'))),
		('sysname', '', N'ColumnName'),
		('text', '', 'Some text'),
		('time', '', '23:59:59.9999999'),
		('timestamp', '', '9999-12-31 23:59:59.9999999'),
		('tinyint', '', '255'),
		('uniqueidentifier', '', 'B8570968-74F0-42A2-B8B6-A2D481EAB630'),
		('varbinary', '', '123456'),
		('varchar', '', 'Some text'),
		('xml', '', '<note>
		<to>Tove</to>
		<from>Jani</from>
		<heading>Reminder</heading>
		<body>Dont forget me this weekend!</body>
		</note>')
		

	DECLARE @counttypes INT = (SELECT COUNT(1) FROM adf.DataType WHERE SystemName = 'MSSQL')
	DECLARE @currenttypeid INT = 0
	DECLARE @comparetypeid INT = 0

	DECLARE @currenttype SYSNAME
	DECLARE @comparetype SYSNAME

	DECLARE @comparetypevalue VARCHAR(8000)

	WHILE (@currenttypeid < @counttypes)
	BEGIN
		SET @currenttype		= (SELECT DataTypeCode FROM adf.DataType WHERE DataTypeID = @currenttypeid)

		DROP TABLE IF EXISTS  ##testtype

		SET @sql_statement = N'CREATE TABLE ##testtype(val ' + @currenttype + ')'
		PRINT @sql_statement
		EXEC sp_executesql @stmt = @sql_statement

		SET @comparetypeid = 0
		WHILE (@comparetypeid < @counttypes)
		BEGIN

			SET @comparetype = (SELECT DataTypeCode FROM adf.DataType WHERE DataTypeID = @comparetypeid)

			-- EXPLICIT CONVERSION
			TRUNCATE TABLE ##testtype

			SET @sql_statement = N'INSERT INTO ##testtype (val) ' + @sql_crlf +
								  'SELECT CONVERT(' + @comparetype + ', TestValue_High) FROM @TestValues WHERE DataType = ''' + @comparetype + ''''
			SET @sql_parameter = N'@TestValues adf.TestValuesTableType READONLY'

			PRINT @sql_statement

			BEGIN TRY
				EXEC @sql_rc = sp_executesql 
							@stmt = @sql_statement
						,	@param = @sql_parameter
						,	@TestValues = @TestValues

				INSERT INTO	@log  (
					SourceType			
				,	TargetType
				,	ConversionType
				,	ConversionResult
				)
				SELECT 
					SourceType			= @currenttype
				,	TargetType			= @comparetype
				,	ConversionType		= 'EXPLICIT'
				,	ConversionResult	= IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)

				IF NOT EXISTS (
					SELECT 1 FROM adf.DataTypeConvertAllow WHERE 
					[SystemName]		=	@SystemName
					AND	[SourceDataTypeID]	=	@currenttypeid
					AND	[TargetDataTypeID]	=	@comparetypeid
				)
				BEGIN
				-- Inserts to the main table 
					INSERT INTO adf.DataTypeConvertAllow (
						[SystemName]
					,	[SourceDataTypeID]
					,	[TargetDataTypeID]
					,	[IsImplicitConvertAllowed]
					,	[IsExplicitConvertAllowed]
					)
					VALUES ( 
						@SystemName
					,	@currenttypeid
					,	@comparetypeid
					,	NULL
					,	 IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)
					)
				END
				ELSE 
				BEGIN 
						-- Updates the main table 
					UPDATE adf.DataTypeConvertAllow 
					SET
						[IsExplicitConvertAllowed] = IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)
					WHERE 
						[SystemName]		=	@SystemName
					AND	[SourceDataTypeID]	=	@currenttypeid
					AND	[TargetDataTypeID]	=	@comparetypeid

				END
			END TRY
			BEGIN CATCH
				INSERT INTO	@log  (
					SourceType			
				,	TargetType
				,	ConversionType
				,	ConversionResult
				)
				SELECT 
					SourceType			= @currenttype
				,	TargetType			= @comparetype
				,	ConversionType		= 'EXPLICIT'
				,	ConversionResult	= 0

				-- Inserts to the main table 
				INSERT INTO adf.DataTypeConvertAllow (
					[SystemName]
				,	[SourceDataTypeID]
				,	[TargetDataTypeID]
				,	[IsImplicitConvertAllowed]
				,	[IsExplicitConvertAllowed]
				)
				VALUES ( 
					@SystemName
				,	@currenttypeid
				,	@comparetypeid
				,	NULL
				,	 IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)
				)

			END CATCH


			-- IMPLICIT CONVERSION
			TRUNCATE TABLE ##testtype

			SET @sql_statement = N'INSERT INTO ##testtype (val) ' + @sql_crlf +
								  'SELECT TestValue_High FROM @TestValues WHERE DataType = ''' + @comparetype + ''''
			SET @sql_parameter = N'@TestValues adf.TestValuesTableType READONLY'


			PRINT @sql_statement

			BEGIN TRY
				EXEC @sql_rc = sp_executesql 
							@stmt = @sql_statement
						,	@param = @sql_parameter
						,	@TestValues = @TestValues


				INSERT INTO	@log  (
					SourceType			
				,	TargetType
				,	ConversionType
				,	ConversionResult
				)
				SELECT 
					SourceType			= @currenttype
				,	TargetType			= @comparetype
				,	ConversionType		= 'IMPLICIT'
				,	ConversionResult	= IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)


				-- Updates the main table 
				UPDATE adf.DataTypeConvertAllow 
				SET
					[IsImplicitConvertAllowed] = IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)
				WHERE 
					[SystemName]		=	@SystemName
				AND	[SourceDataTypeID]	=	@currenttypeid
				AND	[TargetDataTypeID]	=	@comparetypeid
				

			END TRY
			BEGIN CATCH
				INSERT INTO	@log  (
					SourceType			
				,	TargetType
				,	ConversionType
				,	ConversionResult
				)
				SELECT 
					SourceType			= @currenttype
				,	TargetType			= @comparetype
				,	ConversionType		= 'IMPLICIT'
				,	ConversionResult	= 0


				-- Updates the main table 
				UPDATE adf.DataTypeConvertAllow 
				SET
					[IsImplicitConvertAllowed] = IIF(@sql_rc = 0 AND (SELECT COUNT(1) FROM ##testtype) = 1, 1, 0)
				WHERE 
					[SystemName]		=	@SystemName
				AND	[SourceDataTypeID]	=	@currenttypeid
				AND	[TargetDataTypeID]	=	@comparetypeid

			END CATCH
			

			SET @comparetypeid +=  1

		END

		DROP TABLE IF EXISTS  ##testtype

		SET @currenttypeid +=  1
	END
	


	SELECT * FROM @log


END

GO
