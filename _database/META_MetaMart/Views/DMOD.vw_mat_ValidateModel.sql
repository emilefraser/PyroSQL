SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_mat_ValidateModel]
AS
SELECT 
HUB.HubName , HLink.HierarchicalLinkName ,  PKFK.LinkName , Sat.SatelliteName
FROM DMOD.Hub AS HUB,DMOD.HierarchicalLink AS HLink,DMOD.PKFKLink AS PKFK,DMOD.Satellite AS Sat

GO
