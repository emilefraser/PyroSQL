SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[pyro].[ReplaceTokenWithValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Created By: Emile Fraser
-- Date: 2021:02;01
-- Function for my very own template engine
-- Does simple token Replacements 

/*
SELECT 
	''SET IDENTITY_INSERT [dbo].[tablename] {{[ON|OFF]}''
--	''SET IDENTITY_INSERT [dbo].[tablename] ON'' 
,	@TokenValue_Original		''{{[ON|OFF]}''
,	@TokenValue_Replace			''ON''
)
*/


-- SELECT ''
CREATE   FUNCTION [pyro].[ReplaceTokenWithValue] (
	@Value						NVARCHAR(MAX) -- Full Text VALUE
,	@TokenValue_Original		NVARCHAR(MAX) -- Original Token Value
,	@TokenValue_Replace			NVARCHAR(MAX) -- Replacement Token Value
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @AllowableValue TABLE (AllowedValue NVARCHAR(MAX))

	-- Determine if token has only specified Values
   IF (CHARINDEX(''|'', pyro.CleanTokenValue(@TokenValue_Original, ''replace'')) != 0)
   BEGIN
		INSERT INTO @AllowableValue
		SELECT 
			*
		FROM 
			STRING_SPLIT(pyro.CleanTokenValue(@TokenValue_Original, ''replace''), ''|'')
	END

	RETURN N''''




END
' 
END
GO
