SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [DMOD].[vw_Validation_HUB_SAT_LINK_Activity]
as 

select h.HubName, h.IsActive as HUBIsActive,S.SatelliteName, s.HubID, s.IsActive as SatIsActive, pkfk1.LinkName,pkfk1.IsActive as LinkIsActive
from dmod.hub h
left join dmod.Satellite s
on s.HubID = h.HubID
left join dmod.PKFKLink pkfk1
on pkfk1.ChildHubID = h.HubID
where h.IsActive = 0 AND (ISNULL(S.IsActive,0) = 1  OR ISNULL(pkfk1.IsActive,0) = 1)

GO
