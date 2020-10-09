SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- =======================================================================
-- PROCEDURE: DropTestTables
-- If exists then drops the table: #ActualResult
-- If exists then drops the table: #ExpectedResult
-- TODO: Do we need to provide this? 
-- =======================================================================
CREATE PROCEDURE Utils.DropTestTables
AS
BEGIN

   RETURN 
   
   IF (object_id('tempdb..#ExpectedResult') IS NOT NULL) DROP TABLE #ExpectedResult
   IF (object_id('tempdb..#ActualResult') IS NOT NULL) DROP TABLE #ActualResult

END
GO
*/

-- =======================================================================
-- PROCEDURE: DeleteTestTables
-- Deletes all entries from the table: #ActualResult
-- Deletes all entries from the table: #ExpectedResult
-- =======================================================================
CREATE PROCEDURE Utils.DeleteTestTables
AS
BEGIN

   DELETE FROM #ActualResult
   DELETE FROM #ExpectedResult

END

GO
