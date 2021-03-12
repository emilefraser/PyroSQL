SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetQuotedObject]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE     FUNCTION [adf].[GetQuotedObject] (
	@ObjectName				SYSNAME
,	@QuotedIdentifierId		INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
			SELECT 
				REPLACE(QuotedIdentifier_Definition, ''@{{OBJECTNAME}}'', @ObjectName)
			FROM 
				adf.LoadQuotedIdentifier
			WHERE	
				LoadQuotedIdentifierId = @QuotedIdentifierId
	))		
END

' 
END
GO
