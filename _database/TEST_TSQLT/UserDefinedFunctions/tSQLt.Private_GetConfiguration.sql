SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION tSQLt.Private_GetConfiguration(
  @Name NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
  SELECT PC.Name,
         PC.Value 
    FROM tSQLt.Private_Configurations AS PC
   WHERE PC.Name = @Name;

GO
