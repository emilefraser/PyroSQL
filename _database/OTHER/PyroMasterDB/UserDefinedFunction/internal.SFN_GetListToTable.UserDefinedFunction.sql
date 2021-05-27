SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetListToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION SFN_GetListToTable
-- Takes a list with items separated by semicolons and returns a table 
-- where each row contains one item. Each item is max 500 characters otherwise 
-- a truncation error occurs.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetListToTable](@List varchar(max)) 
RETURNS @ListToTable TABLE (ListItem varchar(500) )
AS 
BEGIN

   IF (@List IS NULL) RETURN

   DECLARE @IndexStart  int
   DECLARE @IndexEnd    int
   DECLARE @CrtItem     varchar(500)
   
   SET @IndexStart = 1;
   WHILE (@IndexStart <= DATALENGTH(@List) + 1)
   BEGIN
      SET @IndexEnd = CHARINDEX('';'', @List, @IndexStart)
      IF (@IndexEnd = 0) SET @IndexEnd = DATALENGTH(@List) + 1
      IF (@IndexEnd > @IndexStart)
      BEGIN
         SET @CrtItem = SUBSTRING(@List, @IndexStart, @IndexEnd - @IndexStart)
         INSERT INTO @ListToTable(ListItem) VALUES (@CrtItem)
      END
      
      SET @IndexStart = @IndexEnd + 1
   END

   RETURN
END
' 
END
GO
