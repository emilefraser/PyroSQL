SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE   VIEW [dbo].[vw_ReportingHierarhy_HierarchyID]
AS

WITH DirectReports (OrgPath, EMPLID, NAME)
AS
(
	SELECT
		HIERARCHYID::GetRoot() AS OrgPath
	 -- , HIERARCHYID::GetRoot() AS OrgPath_NAME
	   ,e.EMPLID
	   ,e.NAME
	FROM	
		dbo.SEC_ORG_USER_BASE AS e
	WHERE 
		MGRID IS NULL



	UNION ALL
	SELECT
		CAST(d.OrgPath.ToString() + CAST(e.EMPLID  AS VARCHAR(100)) + '/' AS HierarchyID)
	   -- ,CAST(d.OrgPath.ToString() + CAST(e.NAME  AS VARCHAR(100)) + '/' AS HierarchyID)
	   ,e.EMPLID
	   ,e.NAME
	FROM 
		dbo.SEC_ORG_USER_BASE AS e
	INNER JOIN 
		DirectReports AS d
		ON e.MGRID = d.EMPLID

)
SELECT
	 OrgPath
   , OrgPath.ToString() AS OrgPathString
   , OrgPath.GetLevel() AS OrgLevel
   , EMPLID
   , NAME
FROM 
	DirectReports

GO
