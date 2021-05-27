SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[DeleteTestTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[DeleteTestTables] AS' 
END
GO

/*
-- =======================================================================
-- PROCEDURE: DropTestTables
-- If exists then drops the table: #ActualResult
-- If exists then drops the table: #ExpectedResult
-- TODO: Do we need to provide this? 
-- =======================================================================
CREATE OR ALTER PROCEDURE Utils.DropTestTables
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
ALTER   PROCEDURE [tool].[DeleteTestTables]
AS
BEGIN

   DELETE FROM #ActualResult
   DELETE FROM #ExpectedResult

END
GO
