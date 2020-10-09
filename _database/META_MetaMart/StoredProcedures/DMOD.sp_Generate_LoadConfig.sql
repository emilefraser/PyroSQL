SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Wium Swart
-- Create Date: 12 September
-- Description: Loads loadconfig after building initial loadconfig with app
-- =============================================
-- =======================================================================================================================================

-- =======================================================================================================================================

--Sample Execution: [INTEGRATION].sp_ddl_CreateTable 46743
--exec [DMOD].[sp_Generate_LoadConfig]
CREATE PROCEDURE [DMOD].[sp_Generate_LoadConfig]

AS 
--***************** Temp table filled with loadconfig from app and is manipulated to perform stage load configs  ****************************

--Resets the loads config back to its original modeled state
DELETE FROM DMOD.LoadConfig
WHERE LoadConfigID IN(SELECT DISTINCT LC1.LoadConfigID FROM DMOD.LoadConfig LC1
LEFT JOIN DMOD.LoadConfig LC2
ON LC1.SourceDataEntityID = LC2.TargetDataEntityID
WHERE LC2.LoadConfigID IS not NULL)

UPDATE DMOD.LoadConfig
SET TargetDataEntityID = NULL

DROP TABLE IF EXISTS  #loadconfigtemp 
create table #loadconfigtemp
(
	[LoadConfigID] [int] NULL,
	[SourceDataEntityID] [int] NULL,
	DataEntityTypeID [int] NULL,
	[TargetDataEntityID] [int] NULL,
	[TargetDataEntityname] varchar(200) NULL,
	LoadTypeCode varchar(200) NULL,
    [CreatedDT_FieldID] [int] NULL,
	[UpdatedDT_FieldID] [int] NULL,
	[LoadTypeID] [int] null
)

INSERT INTO #loadconfigtemp
(
	[LoadConfigID],
	[SourceDataEntityID] ,
	DataEntityTypeID ,
	[TargetDataEntityID],
	TargetDataEntityname,
	LoadTypeCode ,
    [CreatedDT_FieldID] ,
	[UpdatedDT_FieldID] )

SELECT	lc.LoadConfigID
		, lc.SourceDataEntityID
		, lt.DataEntityTypeID
		, trgDE.TargetDataEntityID
		, trgDE.TargetDataEntityname
		, lt.LoadTypeCode
		, lc.CreatedDT_FieldID
		, lc.UpdatedDT_FieldID
FROM	DMOD.LoadConfig lc
	INNER JOIN DMOD.LoadType lt
		ON lt.LoadTypeID = lc.LoadTypeID
	INNER JOIN DC.DataEntityType det
		ON det.DataEntityTypeID = lt.DataEntityTypeID
	LEFT JOIN 
				(
					SELECT	DISTINCT lin.SourceDataEntityID
							, lin.SourceDataEntityName							
							, lin.SourceDataEntityTypeCode
							, lin.TargetDataEntityID
							, lin.TargetDataEntityname
							, lin.TargetDataEntityTypeCode
					FROM	[DC].[vw_DCDataLineage] lin
					where	1=1
						AND lin.TargetFieldName = 'BKHash'
						
						AND lin.TargetFieldName <> 'HashDiff'
				) trgDE 
					ON trgDE.TargetDataEntityTypeCode = det.DataEntityTypeCode
						AND lc.SourceDataEntityID = trgDE.sourceDataEntityID

left join dc.DataEntity de1
on de1.DataEntityID = lc.SourceDataEntityID
left join dc.[Schema] s1   
on de1.SchemaID = s1.SchemaID
left join dc.[database] db1
on db1.DatabaseID = s1.DatabaseID

left join dc.DataEntity de2
on de2.DataEntityID = trgDE.TargetDataEntityID
left join dc.[Schema] s2
on de2.SchemaID = s2.SchemaID
left join dc.[database] db2
on db2.DatabaseID = s2.DatabaseID
WHERE LC.IsActive =1
	AND LoadTypeCode like '%Stage%' 
--where db2.DatabaseEnvironmentTypeID = db1.DatabaseEnvironmentTypeID





--****Gives the initial load configs target dataenetityids
UPDATE DMOD.LoadConfig 
SET TargetDataEntityID = LCF.TargetDataEntityID
FROM #loadconfigtemp LCF
WHERE DMOD.LOADCONFIG.LoadConfigID = LCF.LoadConfigID

--** DONT DELETE THIS CODE
update #loadconfigtemp 
set LoadTypeID = j.LoadTypeID1

from (

select LCT.LoadConfigID as LoadConfigID1, /*LCT.*, LC.LoadTypeID, LT.LoadTypeCode,*/ --**** Make Dynamic so that the code doesnt run off hardcoded stuff
CASE
    WHEN LT.LOADTYPECODE LIKE '%LVD%' THEN 35
    WHEN LT.LOADTYPECODE LIKE '%KEYS%' THEN 33
    WHEN LT.LOADTYPECODE LIKE '%MVD%' THEN 36
    WHEN LT.LOADTYPECODE LIKE '%HVD%' THEN 37
	ELSE 6666
END AS LoadTypeID1
from #loadconfigtemp LCT
LEFT JOIN DMOD.LoadConfig LC
ON LC.LoadConfigID = LCT.LoadConfigID
LEFT JOIN DMOD.LoadType LT
ON LC.LoadTypeID = LT.LoadTypeID 
) j
where LoadConfigID = j.LoadConfigID1

						
--***************************************************** Converst the Stage loads to vault loads ***********************************************************
DROP TABLE IF EXISTS  #loadconfigtempVault 
create table #loadconfigtempVault
(
	[LoadConfigID] [int] NULL,
	[SourceDataEntityID] [int] NULL,
	DataEntityTypeID [int] NULL,
	[TargetDataEntityID] [int] NULL,
	[TargetDataEntityname] varchar(200) NULL,
	LoadTypeCode varchar(200) NULL,
    [CreatedDT_FieldID] [int] NULL,
	[UpdatedDT_FieldID] [int] NULL,
)
insert into #loadconfigtempVault
select null as Loadconfigid,k.SourceDataEntityID, k.DataEntityTypeID, k.TargetDataEntityID,de2.DataEntityName as trgtDE,k.loadtypecode, null as created , null as updated--, de1.DataEntityName as srcde, de2.DataEntityName as trgde from (
from (
SELECT	lc.LoadConfigID
		, lc.TargetDataEntityID AS SourceDataEntityID
		, lt.DataEntityTypeID
		, trgDE.TargetDataEntityID
		, trgDE.TargetDataEntityname
		, lt.LoadTypeCode
		, lc.CreatedDT_FieldID
		, lc.UpdatedDT_FieldID
FROM	#loadconfigtemp lc
	INNER JOIN DMOD.LoadType lt
		ON lt.LoadTypeID = lc.LoadTypeID
	INNER JOIN DC.DataEntityType det
		ON det.DataEntityTypeID = lt.DataEntityTypeID
	INNER JOIN 
				(
					SELECT	DISTINCT lin.SourceDataEntityID
							, lin.SourceDataEntityName
							, lin.SourceDataEntityTypeCode
							, lin.TargetDataEntityID
							, lin.TargetDataEntityname
							, lin.TargetDataEntityTypeCode
							,lin.TargetFieldName
					FROM	[DC].[vw_DCDataLineage] lin
					where	1=1
						AND lin.TargetFieldName like 'HK_%'	
				) trgDE 
				ON trgDE.TargetDataEntityTypeCode = det.DataEntityTypeCode
				and lc.TargetDataEntityID = trgDE.sourceDataEntityID
) k
left join dc.DataEntity de1
on k.SourceDataEntityID = de1.DataEntityID
left join dc.DataEntity de2
on k.TargetDataEntityID = de2.DataEntityID


left join dc.[Schema] s1   
on de1.SchemaID = s1.SchemaID
left join dc.[database] db1
on db1.DatabaseID = s1.DatabaseID

left join dc.[Schema] s2
on de2.SchemaID = s2.SchemaID
left join dc.[database] db2
on db2.DatabaseID = s2.DatabaseID

--where db2.DatabaseEnvironmentTypeID = db1.DatabaseEnvironmentTypeID



--***************************************************** INSERTS HUBS & SATS ***********************************************************

INSERT INTO DMOD.LoadConfig
(
[LoadTypeID], 
	[SourceDataEntityID] ,
	[TargetDataEntityID] ,
	[IsSetForReloadOnNextRun] ,
	[OffsetDays],
	[CreatedDT_FieldID],
	[UpdatedDT_FieldID],
	[CreatedDT],
	[UpdatedDT],
	[IsActive] 
)

select --NULL as LoadConfigID, --WILL INSERT HUB AND SATS OF VAULT INTO LOAD CONFIG
CASE 
   WHEN lct.TargetDataEntityname LIKE 'HUB%' THEN 33
   WHEN lct.TargetDataEntityname LIKE 'LINK%' THEN 34
   WHEN lct.TargetDataEntityname LIKE '%LVD' THEN 35
   WHEN lct.TargetDataEntityname LIKE '%MVD' THEN 36
   WHEN lct.TargetDataEntityname LIKE '%HVD' THEN 37
   ELSE 66666
   END  AS LoadTypeID,
lct.SourceDataEntityID,
lct.TargetDataEntityID,
0,
NULL,
NULL,
NULL,
GETDATE(),
NULL,
1
--,TargetDataEntityname
from #loadconfigtempVault lct
	INNER JOIN DMOD.LoadType lt ON
		lt.LoadTypeCode = lct.LoadTypeCode
WHERE NOT EXISTS ( SELECT 1 FROM DMOD.LoadConfig
					WHERE SourceDataEntityID = lct.SourceDataEntityID
							AND TargetDataEntityID = lct.TargetDataEntityID
							AND LoadTypeID = lt.LoadTypeID
									
				  )

--SELECT * FROM DMOD.LoadConfig --113 WAS LAST LOAD  NB!!!

--******************************************************* INSERTS LINKS *************************************************************
INSERT INTO DMOD.LoadConfig
(
[LoadTypeID], 
	[SourceDataEntityID] ,
	[TargetDataEntityID] ,
	[IsSetForReloadOnNextRun] ,
	[OffsetDays],
	[CreatedDT_FieldID],
	[UpdatedDT_FieldID],
	[CreatedDT],
	[UpdatedDT],
	[IsActive] 
)




select    --THIS WILL INSERT ALL THE LOAD CONFIGS FOR LINKS INTO THE LOAD CONFIG
--NULL,
/*CASE 
   WHEN DE1.DataEntityName LIKE 'HUB%' THEN 33
   WHEN DE1.DataEntityName LIKE 'LINK%' THEN 34
   WHEN DE1.DataEntityName LIKE '%LVD' THEN 35
   WHEN DE1.DataEntityName LIKE '%MVD' THEN 36
   WHEN DE1.DataEntityName LIKE '%HVD' THEN 37
   ELSE 6666666
   END*/ 34  AS LoadTypeID,
lcv.SourceDataEntityID,
de.DataEntityID as TargetDataEntityID,
--z.LinkName as TargetDataEntityName ,
--DE1.DataEntityName,
0,
NULL,
NULL,
NULL,
GETDATE(),
NULL,
1
FROM #loadconfigtempVault LCV
LEFT JOIN DMOD.HUB H
ON H.HUBNAME = LCV.TARGETDATAENTITYNAME
LEFT JOIN DMOD.PKFKLINK PFL
ON PFL.CHILDHUBID = H.HUBID
LEFT JOIN DC.DataEntity DE
ON DE.DataEntityName = PFL.LinkName



LEFT JOIN DC.DataEntity DE1
ON DE1.DataEntityID = lcv.TargetDataEntityID
LEFT JOIN DC.[Schema] S1
ON S1.SchemaID = DE1.SchemaID
LEFT JOIN DC.[Database] DB1
ON DB1.DatabaseID = S1.DatabaseID

LEFT JOIN DC.DataEntity DE2
ON DE2.DataEntityID = de.DataEntityID
LEFT JOIN DC.[Schema] S2
ON S2.SchemaID = DE2.SchemaID
LEFT JOIN DC.[Database] DB2
ON DB2.DatabaseID = S2.DatabaseID

WHERE PFL.PKFKLinkID IS NOT NULL
and PFL.IsActive = 1
and db1.DatabaseID = db2.DatabaseID
and db1.DatabaseEnvironmentTypeID = db2.DatabaseEnvironmentTypeID


DELETE FROM DMOD.LoadConfig                        --This step is added so that if field relations are not correct or have changed the list of load configs does not grow unnecisarily 
WHERE LoadConfigID IN( 
SELECT LC1.LoadConfigID FROM dmod.LoadConfig lc1
INNER JOIN dmod.LoadConfig lc2
ON lc2.SourceDataEntityID = lc1.SourceDataEntityID
AND lc2.LoadTypeID = lc1.LoadTypeID
WHERE lc1.TargetDataEntityID is null
AND lc2.TargetDataEntityID is not null
)





GO
