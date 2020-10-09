SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_mat_Server] AS

SELECT 
svr.ServerID AS [Server ID],
svr.ServerName AS [Server Name],
svr.PublicIP AS [Public IP],
svr.LocalIP AS [Local IP],
svr.UserID AS [User ID],
svr.AccessInstructions AS [Access Instructions],
svr.CreatedDT AS [Created Date],
svr.UpdatedDT AS [Updated Date],
svr.IsActive AS [Is Active],
svr.ServerTypeID AS [Server Type ID],
svr.ServerLocationID AS [Server Location ID],
st.ServerTypeDescription AS [Server Type Description],
svrl.[ServerLocationCode] AS [Server Location Code],
svrl.[ServerLocationName] AS [Server Location Name],
svrl.[IsCloudLocation] AS [Is Cloud Location]

FROM [DC].[Server] svr
LEFT JOIN [DC].[ServerType] st
ON svr.ServerTypeID = st.ServerTypeID
LEFT JOIN [DC].[ServerLocation] svrl
ON svr.ServerLocationID = svrl.ServerLocationID

GO
