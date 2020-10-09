SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [dbo].[vw_ReportingHierarhy]
AS

WITH DirectReports (MGRID, EMPLID, NAME, MGR, ORG_UNIT_ID, ORG_UNIT_NAME, Level, ORG_LINEAGE, ORG_NAME_LINEAGE, NAME_LINEAGE)
AS
(
    SELECT e.MGRID, e.EMPLID, e.NAME, cast(null as varchar(50)) as MGR, e.ORG_UNIT_ID, e.ORG_UNIT_NAME,
        0 AS Level, 
		cast(e.ORG_UNIT_ID as varchar(max)) as ORG_LINEAGE,
		cast(e.ORG_UNIT_NAME as varchar(max)) as ORG_NAME_LINEAGE,
		cast(e.NAME as varchar(max)) as NAME_LINEAGE
    FROM dbo.SEC_ORG_USER_BASE AS e
    WHERE MGRID IS NULL
    UNION ALL
    SELECT e.MGRID, e.EMPLID, e.NAME, d.NAME, e.ORG_UNIT_ID, e.ORG_UNIT_NAME, 
        Level + 1, 
		case when e.org_unit_id <> d.org_unit_id then cast(d.ORG_LINEAGE + '|' + cast(e.ORG_UNIT_ID as varchar(max)) as varchar(max)) else cast(d.ORG_LINEAGE as varchar(max)) end, 
		case when e.ORG_UNIT_NAME <> d.ORG_UNIT_NAME then cast(d.ORG_NAME_LINEAGE + '|' + e.ORG_UNIT_NAME as varchar(max)) else cast(d.ORG_NAME_LINEAGE as varchar(max)) end,
		case when e.NAME <> d.NAME then cast(d.NAME + '|' + e.NAME as varchar(max)) else cast(d.NAME as varchar(max)) end
    FROM dbo.SEC_ORG_USER_BASE AS e
    INNER JOIN DirectReports AS d
        ON e.MGRID = d.EMPLID
)
SELECT MGRID, EMPLID, NAME, MGR, ORG_UNIT_ID, ORG_UNIT_NAME, Level, ORG_LINEAGE, ORG_NAME_LINEAGE, NAME_LINEAGE
FROM DirectReports


GO
