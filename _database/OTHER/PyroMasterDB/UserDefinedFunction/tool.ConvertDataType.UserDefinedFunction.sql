SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[ConvertDataType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Converts Data Types (code + text)

	Test1: SELECT [tool].[ConvertDataType]( ''DEC'', ''ABAP'', ''000020'', ''000020'', ''X'', ''MSSQL'')

*/
CREATE   FUNCTION [tool].[ConvertDataType] (
    @SourceDataType				SYSNAME
,	@SourceTechnologyTypeCode	SYSNAME
,	@SourceDataTypeLength		NVARCHAR(20)	= NULL
,	@SourceDataTypeDecimal		NVARCHAR(20)	= NULL
,	@SourceDataTypeIsNullable	NVARCHAR(20)	= NULL
,	@TagetTechnologyTypeCode	SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN


--declare 
--   @SourceDataType				SYSNAME = ''DEC''
--,	@SourceTechnologyTypeCode	SYSNAME = ''ABAP''
--,	@SourceDataTypeLength		NVARCHAR(20)	= ''000020''
--,	@SourceDataTypeDecimal		NVARCHAR(20)	= ''000020''
--,	@SourceDataTypeIsNullable	NVARCHAR(20)	= ''X''
--,	@TagetTechnologyTypeCode	SYSNAME =  ''MSSQL''

	DECLARE 
		@sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab			NVARCHAR(1) = CHAR(9)

	DECLARE 
		@SourceDataTypeLengthValue		INT = CONVERT(INT, @SourceDataTypeLength)
	,	@SourceDataTypeDecimalValue		INT = CONVERT(INT, @SourceDataTypeDecimal)
	,	@SourceDataTypeIsNullableValue	BIT = IIF(UPPER(@SourceDataTypeIsNullable) = ''X'', 0, 1)

	DECLARE 
		@SourceDataTypeFormat				NVARCHAR(MAX)
	,	@SourceDataTypeMaxLengthDefault		INT
	,	@SourceDataTypePrecisionDefault		INT
	,	@SourceDataTypeScaleDefault			INT
	,	@SourceDataTypeIsNullableDefault	BIT
	,	@TargetDataTypeCode					NVARCHAR(MAX)
	,	@TargetDataTypeFormat				NVARCHAR(MAX)
	,	@TargetDataTypeMaxLengthDefault		INT
	,	@TargetDataTypePrecisionDefault		INT
	,	@TargetDataTypeScaleDefault			INT
	,	@TargetDataTypeIsNullableDefault	BIT

	DECLARE 
		@ReturnValue						NVARCHAR(MAX)	=	''''
	,	@DataTypeFinal						NVARCHAR(MAX)	=	''''
	,	@DataTypeMaxLengthFinal				INT
	,	@DataTypeScaleFinal					INT
	,	@DataTypePrecisionFinal				INT
	,	@DataTypeIsNullableFinal			BIT

	-- Gets the default values
	SELECT 
		@SourceDataTypeFormat					= vdtc.SourceDataTypeFormat
	,	@SourceDataTypeMaxLengthDefault			= vdtc.SourceDataTypeMaxLength
	,	@SourceDataTypePrecisionDefault			= vdtc.SourceDataTypePrecision
	,	@SourceDataTypeScaleDefault				= vdtc.SourceDataTypeScale
	,	@SourceDataTypeIsNullableDefault		= vdtc.SourceDataTypeIsNullable
	,	@TargetDataTypeCode						= vdtc.TargetDataTypeCode
	,	@TargetDataTypeFormat					= vdtc.TargetDataTypeFormat
	,	@TargetDataTypeMaxLengthDefault			= vdtc.TargetDataTypeMaxLength
	,	@TargetDataTypePrecisionDefault			= vdtc.TargetDataTypePrecision
	,	@TargetDataTypeScaleDefault				= vdtc.TargetDataTypeScale
	,	@TargetDataTypeIsNullableDefault		= vdtc.TargetDataTypeIsNullable
	FROM 									  
		[tool].[vw_DataTypeConvert] AS vdtc
	WHERE 
		vdtc.SourceDataTypeCode = @SourceDataType
	AND 
		vdtc.SourceTechnologyCode = @SourceTechnologyTypeCode
	AND 
		vdtc.TargetTechnologyCode = @TagetTechnologyTypeCode


	--SELECT @SourceDataTypeFormat ,@SourceDataTypeMaxLengthDefault, @SourceDataTypePrecisionDefault , @SourceDataTypeScaleDefault
	--SELECT @TargetDataTypeCode ,@TargetDataTypeFormat, @TargetDataTypePrecisionDefault ,@TargetDataTypeScaleDefault, @TargetDataTypeIsNullableDefault
	

	SELECT 
		@DataTypeFinal				= @TargetDataTypeCode
	,	@DataTypeMaxLengthFinal		= CASE 
										WHEN @SourceDataTypeLengthValue IS NOT NULL
											THEN @SourceDataTypeLengthValue
										WHEN @SourceDataTypeMaxLengthDefault < @TargetDataTypeMaxLengthDefault
											THEN @SourceDataTypeMaxLengthDefault
										ELSE
											@TargetDataTypeMaxLengthDefault
									END
	,	@DataTypePrecisionFinal		= CASE 
										WHEN @SourceDataTypeLengthValue IS NOT NULL
											THEN @SourceDataTypeLengthValue
										WHEN @SourceDataTypePrecisionDefault < @TargetDataTypePrecisionDefault
											THEN @SourceDataTypePrecisionDefault
										ELSE
											@TargetDataTypePrecisionDefault
									END
	,	@DataTypeScaleFinal			= CASE 
										WHEN @SourceDataTypeDecimalValue IS NOT NULL
											THEN @SourceDataTypeDecimalValue
										WHEN @SourceDataTypeScaleDefault < @TargetDataTypeScaleDefault
											THEN @SourceDataTypeScaleDefault
										ELSE
											@TargetDataTypeScaleDefault
									END
			
	,	@DataTypeIsNullableFinal =	 CASE 
										WHEN @SourceDataTypeIsNullableValue IS NOT NULL
											THEN @SourceDataTypeIsNullableValue
										WHEN @SourceDataTypeIsNullableDefault < @TargetDataTypeIsNullableDefault
											THEN @SourceDataTypeIsNullableDefault
										ELSE
											@TargetDataTypeIsNullableDefault
									END

	-- Ghost record fix
	IF(@DataTypeMaxLengthFinal - @DataTypeScaleFinal) <=4
	BEGIN
		SET @DataTypeMaxLengthFinal = @DataTypeMaxLengthFinal + ( 4 - (@DataTypeMaxLengthFinal - @DataTypeScaleFinal))
	END

	-- Precision 
	IF(@DataTypePrecisionFinal - @DataTypeScaleFinal) <=4
	BEGIN
		SET @DataTypePrecisionFinal = @DataTypePrecisionFinal + ( 4 - (@DataTypePrecisionFinal - @DataTypeScaleFinal))
	END


	SET  @ReturnValue = 
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								@TargetDataTypeFormat, ''{{@datatype}}'', @DataTypeFinal
							) , ''{{@length}}'', CONVERT(VARCHAR(6), @DataTypeMaxLengthFinal)
						) , ''{{@precision}}'', CONVERT(VARCHAR(6), @DataTypePrecisionFinal)
					), ''{{@scale}}'', CONVERT(VARCHAR(6), @DataTypeScaleFinal)
				), ''{{@isnullable}}'', IIF(@DataTypeIsNullableFinal = 1, ''NULL'', ''NOT NULL'')
			)


	RETURN @ReturnValue
	--RETURN @sql_message

END

' 
END
GO
