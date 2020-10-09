SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION dbo.fn_sysutility_get_culture_invariant_conversion_style_internal (@data_type varchar(30))
RETURNS tinyint
AS 
BEGIN
   RETURN 
      CASE 
         -- ISO8601, e.g. "yyyy-mm-ddThh:mi:ss.mmm"
         WHEN @data_type IN ('datetime', 'datetimeoffset', 'smalldatetime', 'datetime2', 'date', 'time') THEN 126
         -- scientific notation, 16 digits
         WHEN @data_type IN ('real', 'float') THEN 2
         -- e.g. "0x12AB"
         WHEN @data_type IN ('binary', 'varbinary') THEN 1 
         -- all other types including bit, integer types, (n)varchar, decimal/numeric
         ELSE 0 
      END;
END;

GO
