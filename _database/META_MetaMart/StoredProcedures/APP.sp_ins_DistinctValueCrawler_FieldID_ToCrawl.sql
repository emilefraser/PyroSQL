SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [APP].[sp_ins_DistinctValueCrawler_FieldID_ToCrawl]
@FieldID INT
AS

DECLARE @TempTable TABLE 
(FieldID INT)
INSERT INTO @TempTable
SELECT FieldID 
FROM DC.vw_rpt_DatabaseFieldDetail
WHERE FieldID = @FieldID

TRUNCATE TABLE APP.SortOrderCrawler
INSERT INTO APP.SortOrderCrawler
SELECT FieldID
FROM @TempTable tt
WHERE NOT EXISTS (SELECT 1 
				  FROM APP.SortOrderCrawler soc
				  WHERE soc.FieldID = tt.FieldID
				  )

GO
