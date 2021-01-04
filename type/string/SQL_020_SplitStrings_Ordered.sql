USE master;
GO
IF OBJECT_ID('[dbo].[SplitStrings_Ordered]') IS NOT NULL 
DROP  FUNCTION  [dbo].[SplitStrings_Ordered] 
GO
CREATE FUNCTION [dbo].[SplitStrings_Ordered] (@List      VARCHAR(8000),
                                              @Delimiter VARCHAR(255))
RETURNS TABLE
AS
    RETURN
      (SELECT [Index] = ROW_NUMBER()
                          OVER (
                            ORDER BY Number),
              Item
       FROM   (SELECT Number,
                      Item = Substring(@List, Number, Charindex(@Delimiter, @List + @Delimiter, Number) - Number)
               FROM   (SELECT ROW_NUMBER()
                                OVER (
                                  ORDER BY [object_id])
                       FROM   sys.all_columns) AS n(Number)
               WHERE  Number <= CONVERT(INT, Len(@List))
                      AND Substring(@Delimiter + @List, Number, Len(@Delimiter)) = @Delimiter) AS y); 
GO

--#################################################################################################
--Public permissions
GRANT SELECT ON [SplitStrings_Ordered] TO PUBLIC
--#################################################################################################
GO
