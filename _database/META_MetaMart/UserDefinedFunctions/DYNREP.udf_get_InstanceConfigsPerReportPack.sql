SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--TODO Loop through all report lines and get config values
--SELECT ReportBaseID FROM DYNREP.ReportLineExtension


CREATE FUNCTION [DYNREP].[udf_get_InstanceConfigsPerReportPack]
(@ReportPackID int)
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
 ,LineAmount bigint
)
AS
	BEGIN
--DECLARE @TempTable1 TABLE 
--(ID int,ReportBaseLineID int,ReportInstanceID varchar(100))

--INSERT INTO @TempTable1
--SELECT ROW_NUMBER() OVER(ORDER BY rb.ReportBaseID) AS ID
--	  ,ReportBaseID AS ReportBaseLineID
--	  ,ReportBaseParentID AS ReportInstanceID
--FROM DYNREP.ReportBase rb
--WHERE rb.ReportBaseParentID = @ReportPackID

--DECLARE @TotalRows INT=(SELECT COUNT(*) FROM @TempTable1),@i INT=1 -- Get total rows and set counter to 1
--WHILE @i<=@TotalRows -- begin as long as i (counter) is less than or equal to the total number of records
	BEGIN
--	--LINE LEVEL CONFIG
	INSERT INTO @TempTable
						 
								SELECT	rb.ReportBaseID AS ReportBaseID
										,NULL
										,rl.[ReportInstanceName] as ReportInstanceName
										,NULL
										,rb.ReportBaseParentID
										,DYNREP.udf_get_ConfigValueForReportLine ('SIZE',@ReportPackID) AS SIZE
										,DYNREP.udf_get_ConfigValueForReportLine ('FONT',@ReportPackID) AS FONT
										,DYNREP.udf_get_ConfigValueForReportLine ('COLOUR',@ReportPackID) AS COLOUR
										,DYNREP.udf_get_ConfigValueForReportLine ('BOLD',@ReportPackID) AS BOLD
										,NULL AS LineAmount
								FROM	DYNREP.ReportInstanceExtension rl
									INNER JOIN	DYNREP.ReportBase rb
													ON rb.ReportBaseID = rl.ReportBaseID
		--SET @i = @i +1

	END 
RETURN
END
--GO
--UNION ALL

--SELECT	rb.ReportBaseID
--		,rhi.ReportingHierarchyItemID
--		,rhi.ItemName as ReportLineName
--		,rhi.ReportingHierarchySortOrder
--		,rb.ReportBaseParentID
--		,DYNREP.udf_get_ConfigValueForReportLine ('SIZE',@ReportBaseLineID2) AS SIZE
--		,DYNREP.udf_get_ConfigValueForReportLine ('FONT',@ReportBaseLineID2) AS FONT
--		,DYNREP.udf_get_ConfigValueForReportLine ('COLOUR',@ReportBaseLineID2) AS COLOUR
--		,DYNREP.udf_get_ConfigValueForReportLine ('BOLD',@ReportBaseLineID2) AS BOLD
--FROM	DYNREP.ReportLineExtension rl
--	INNER JOIN	DYNREP.ReportBase rb
--					ON rb.ReportBaseID = rl.ReportBaseID
--	LEFT JOIN	[MASTER].ReportingHierarchyItem rhi
--					ON rl.ReportingHierarchyItemID = rhi.ReportingHierarchyItemID
--WHERE rb.ReportBaseID = @ReportBaseLineID2

GO
