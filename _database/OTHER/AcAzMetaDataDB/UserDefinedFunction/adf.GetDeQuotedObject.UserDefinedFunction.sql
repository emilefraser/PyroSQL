SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetDeQuotedObject]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE       FUNCTION [adf].[GetDeQuotedObject] (
	@ObjectName				SYSNAME
,	@QuotedIdentifierId		INT		= NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
			SELECT
				CASE ([QuotedIdentifierCode])
					WHEN ''QUOTE'' 
						THEN REPLACE(@ObjectName, ''"'', '''')
					WHEN ''SQUARBRACKET'' 
						THEN PARSENAME(@ObjectName, 1)
					ELSE 
						@ObjectName
				END
			FROM 
				adf.LoadQuotedIdentifier
			WHERE	
				LoadQuotedIdentifierId = @QuotedIdentifierId
	))		
END

' 
END
GO
