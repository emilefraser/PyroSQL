SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DetermineVariant]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[DetermineVariant]()

RETURNS NVARCHAR(20)
AS
BEGIN
DECLARE @one TINYINT
DECLARE @two VARCHAR(20)

SET @one = 1
SET @two = ''2''

/*SELECT @one + @two AS ''ValueOfAggregate''
,	SQL_VARIANT_PROPERTY(@one + @two,''basetype'') AS ''ResultOfExpression''
, SQL_VARIANT_PROPERTY(@one + @two,''precision'') AS ''ResultOfPrecision''
, SQL_VARIANT_PROPERTY(@one,''basetype'') AS ''DataTypeOf @one''
, SQL_VARIANT_PROPERTY(@one,''precision'') AS ''PrecisionOf @one''
, SQL_VARIANT_PROPERTY(@one,''scale'') AS ''ScaleOf @one''
, SQL_VARIANT_PROPERTY(@one,''MaxLength'') AS ''MaxLengthOf @one''
, SQL_VARIANT_PROPERTY(@one,''Collation'') AS ''CollationOf @one''
, SQL_VARIANT_PROPERTY(@two,''basetype'') AS ''DataTypeOf @two''
, SQL_VARIANT_PROPERTY(@two,''precision'') AS ''PrecisionOf @two''
*/
RETURN @two

END
' 
END
GO
