SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitTextWithDelimiterInt]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	Creates a Dynamic SQL Insert Statement

	(Usage)	
					SELECT * FROM [template].[ObjectName] (@Parameter1, @Parameter2)
	(/Usage)
##}}
*/
/*
Overloaded version to make splitting comma seperated lists of ints easier.
Note the delimiter is hard coded to comma and that non-int values will be removed.
*/
CREATE   FUNCTION [string].[SplitTextWithDelimiterInt] (
	@Text nvarchar(max)  -- Text to split
)
RETURNS TABLE
AS
RETURN SELECT [item_int] -- TODO: Optional add distinct?
	FROM [string].[SplitTextWithDelimiter](@Text, '','') -- Hard coded to comma delimited
	WHERE [item_int] IS NOT NULL -- Remove invalid values
' 
END
GO
