
CREATE FUNCTION dbo.ColumnList (@ObjectId int, @AliasPrefix nvarchar(10), @include_identity_column bit, @include_computed_columns bit, @include_timestamp_columns bit) 
RETURNS nvarchar(max) 
WITH EXECUTE AS CALLER 
AS
/* www.dynamic-sql-and-biml.com */
BEGIN
RETURN( 
 select  stuff(
   ( select     ISNULL(convert(nvarchar(max), N', ' + @AliasPrefix + N'.'), N', ') + convert(nvarchar(max), quotename(c.name))
    from       sys.columns         c 
      where      c.object_id         =   @ObjectId 
        and  c.is_identity       =   isnull(nullif(@include_identity_column, 1 ), c.is_identity)
        and c.is_computed       =   isnull(nullif(@include_computed_columns, 1 ), c.is_computed)
        and (
                            c.system_type_id    <>  TYPE_ID('timestamp') 
                            or
                            isnull(@include_timestamp_columns, 1) = 1
                            ) 
      ORDER BY    c.column_id 
      FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
        ,1,1,'') 
) 
END