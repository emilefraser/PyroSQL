DECLARE @one TINYINT
DECLARE @two VARCHAR(20)

SET @one = 1
SET @two = '2'

SELECT @one + @two AS 'ValueOfAggregate'
,	SQL_VARIANT_PROPERTY(@one + @two,'basetype') AS 'ResultOfExpression'
, SQL_VARIANT_PROPERTY(@one + @two,'precision') AS 'ResultOfPrecision'
, SQL_VARIANT_PROPERTY(@one,'basetype') AS 'DataTypeOf @one'
, SQL_VARIANT_PROPERTY(@one,'precision') AS 'PrecisionOf @one'
, SQL_VARIANT_PROPERTY(@one,'scale') AS 'ScaleOf @one'
, SQL_VARIANT_PROPERTY(@one,'MaxLength') AS 'MaxLengthOf @one'
, SQL_VARIANT_PROPERTY(@one,'Collation') AS 'CollationOf @one'
, SQL_VARIANT_PROPERTY(@two,'basetype') AS 'DataTypeOf @two'
, SQL_VARIANT_PROPERTY(@two,'precision') AS 'PrecisionOf @two'