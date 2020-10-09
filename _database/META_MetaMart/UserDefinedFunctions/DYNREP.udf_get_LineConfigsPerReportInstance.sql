SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


--TODO Loop through all report lines and get config values
--SELECT ReportBaseID FROM DYNREP.ReportLineExtension


CREATE FUNCTION [DYNREP].[udf_get_LineConfigsPerReportInstance]
(@ReportInstanceID int)
RETURNS @TempTable TABLE
( ReportBaseID int
 ,ReportingHierarchyItemID int
 ,ReportLineName varchar(200)
 ,SortOrder int
 ,ReportBaseParentID int
 ,Size int
 ,Font varchar(100)
 ,Color varchar(100)
 ,BOLD bit
 ,Interior varchar(100)
 ,LineAmount bigint
)
AS
BEGIN
DECLARE @TempTable1 TABLE 
(ID int,ReportBaseLineID int,ReportInstanceID varchar(100))

INSERT INTO @TempTable1
SELECT ROW_NUMBER() OVER(ORDER BY rb.ReportBaseID) AS ID
	  ,ReportBaseID AS ReportBaseLineID
	  ,ReportBaseParentID AS ReportInstanceID
FROM DYNREP.ReportBase rb
WHERE rb.ReportBaseParentID = @ReportInstanceID

DECLARE @TotalRows INT=(SELECT COUNT(*) FROM @TempTable1),@i INT=1 -- Get total rows and set counter to 1
WHILE @i<=@TotalRows -- begin as long as i (counter) is less than or equal to the total number of records
	BEGIN
	--LINE LEVEL CONFIG
	INSERT INTO @TempTable
						 
								SELECT	rb.ReportBaseID
										,rhi.ReportingHierarchyItemID
										,rhi.ItemName as ReportLineName
										,rhi.ReportingHierarchySortOrder
										,rb.ReportBaseParentID
										,DYNREP.udf_get_ConfigValueForReportLine ('SIZE',(SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)) AS SIZE
										,DYNREP.udf_get_ConfigValueForReportLine ('FONT',(SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)) AS FONT
										,DYNREP.udf_get_ConfigValueForReportLine ('COLOUR',(SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)) AS COLOUR
										,DYNREP.udf_get_ConfigValueForReportLine ('BOLD',(SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)) AS BOLD
										,DYNREP.udf_get_ConfigValueForReportLine ('INTERIOR',(SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)) AS BOLD
										,amount.ActualYTDAmount
								FROM	DYNREP.ReportLineExtension rl
									INNER JOIN	DYNREP.ReportBase rb
													ON rb.ReportBaseID = rl.ReportBaseID
									LEFT JOIN	[MASTER].ReportingHierarchyItem rhi
													ON rl.ReportingHierarchyItemID = rhi.ReportingHierarchyItemID
									LEFT JOIN 
									(SELECT	rh.ReportingHierarchyItemID, SUM(Balance) as ActualYTDAmount
										FROM	
											(	
											SELECT	rhi.ReportingHierarchyItemID, lbk.BusinessKey
											FROM	[MASTER].ReportingHierarchyItem rhi
												INNER JOIN [MASTER].LinkReportingHierarchyItemToBKCombination  lrhibk 
															ON rhi.ReportingHierarchyItemID = lrhibk.ReportingHierarchyItemID
												INNER JOIN [MASTER].LinkBKCombination lbk 
															ON lrhibk.LinkID = lbk.LinkID
											WHERE rhi.IsActive = 1
												AND lbk.IsActive = 1
											)rh

										LEFT JOIN	DEV_InfoMart..vw_FactFinancialActual fa
														ON rh.BusinessKey = fa.AccountNumber
										WHERE FinancialYear = 2019 AND FinancialPeriod = 11
										GROUP BY rh.ReportingHierarchyItemID) amount ON
											amount.ReportingHierarchyItemID = rhi.ReportingHierarchyItemID
								WHERE rb.ReportBaseID = (SELECT tt.ReportBaseLineID FROM @TempTable1 tt WHERE ID = @i)
		SET @i = @i +1

	END 
RETURN
END

GO
