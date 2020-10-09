SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE VIEW [DC].[vw_mat_DatabaseInstance] AS
SELECT
dbi.DatabaseInstanceID AS [Database Instance ID],
CASE WHEN dbi.IsDefaultInstance = 1 THEN 'Default' ELSE dbi.DatabaseInstanceName END AS [Database Instance Name],
dbi.ServerID AS [Server ID],
dbi.DatabaseAuthenticationTypeID AS [Database Authentication Type ID], 
dat.DBAuthTypeName AS [Database Authentication Type Name],
dbi.AuthUsername AS [Auth Username],
dbi.AuthPassword AS [Auth Password],
dbi.IsDefaultInstance AS [Is Default Instance],
dbi.NetworkPort AS [Network Port],
dbi.CreatedDT AS [Created Date],
dbi.UpdatedDT AS [Updated Date],
dbi.IsActive AS [Is Active],
s.ServerName AS [Server Name],
dbi.DatabaseTechnologyTypeID AS [Database Technology Type ID],
dbt.DatabaseTechnologyTypeCode AS [Database Technology Type Code],
dbt.DatabaseTechnologyTypeName AS [Database Technology Type Name],
dbi.ADFLinkedServiceID AS [ADF Linked Service ID],
adf.ADFLinkedServiceCode AS [ADF Linked Service Code],
adf.ADFLinkedServiceName AS [ADF Linked Service Name],
adf.IntegrationRuntimeID AS [Integration Runtime ID]

FROM DC.DatabaseInstance dbi
LEFT JOIN [DC].[Server] s 
ON dbi.ServerID = s.ServerID 
LEFT JOIN [DC].[DatabaseAuthenticationType] dat
ON dbi.DatabaseAuthenticationTypeID = dat.DatabaseAuthenticationTypeID
LEFT JOIN [DC].[DatabaseTechnologyType] dbt
ON dbi.DatabaseTechnologyTypeID = dbt.DatabaseTechnologyTypeID
LEFT JOIN [DC].[ADFLinkedService] adf
ON dbi.ADFLinkedServiceID = adf.ADFLinkedServiceID

GO
