SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[pyro].[CleanTokenValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Created By: Emile Fraser
-- Date: 2021:02;01
-- Function for my very own template engine
-- Cleans token for futher string analyis

-- SELECT [pyro].[CleanTokenValue](''{{hello}}'', ''replace'')

CREATE   FUNCTION [pyro].[CleanTokenValue] (
	@TokenValue					NVARCHAR(MAX) -- Original Token Value
,	@TokenTypeCode				NVARCHAR(50)	= ''dummy''
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @Return_Value NVARCHAR(MAX)

	DECLARE 
		@TokenTypeDefinition	NVARCHAR(MAX)
	,	@TokenBraceLeft			NVARCHAR(50)
	,	@TokenBraceRight		NVARCHAR(50)
	,	@TokenTranslationSql	NVARCHAR(MAX)

	SELECT 
		@TokenTypeDefinition	= TokenTypeDefinition
	,	@TokenBraceLeft			= TokenBraceLeft
	,	@TokenBraceRight		= TokenBraceRight
	,	@TokenTranslationSql	= TokenTranslationSql
	FROM 
		[pyro].[TokenType]
	WHERE
		[TokenTypeCode] = @TokenTypeCode

	--SELECT @TokenTypeDefinition, @TokenBraceLeft, @TokenBraceRight, @TokenTranslationSql

	SET @Return_Value = REPLACE(REPLACE(@TokenValue, @TokenBraceLeft, ''''), @TokenBraceRight, '''')

	RETURN @Return_Value
	


END
' 
END
GO
