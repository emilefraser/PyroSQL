SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[GenerateDateFormat]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
{{META>}}
	{Written By}	Emile Fraser
	{CreatedDate}	2021-01-22
	{UpdatedDate}	2021-01-22
	{Description}	Shows various date formats at formatvalues, expressions and formulas

	{Usage}			SELECT * FROM [dim].[GenerateDateFormat](GETDATE())

{{<META}}
--*/
CREATE   FUNCTION [dt].[GenerateDateFormat] (
	@DateTimeValue	DATETIME2(7)
)
RETURNS TABLE
RETURN
	SELECT 
		DateValueName		= ''Original Date''
	,	DateClassID			= 0
	,	DateValueID			= 0
	,	DateFormatString	= ''GETDATE()''
	,	DateFormatValue		= NULL
	,	DateValue			= @DateTimeValue
' 
END
GO
