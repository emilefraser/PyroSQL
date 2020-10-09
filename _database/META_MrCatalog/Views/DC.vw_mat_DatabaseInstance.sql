SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_mat_DatabaseInstance] AS
SELECT
DatabaseInstanceID AS [Database Instance ID],
DatabaseInstanceName AS [Database Instance Name],
ServerID AS [Server ID],
DatabaseAuthenticationTypeID AS [Database Authentication Type ID], 
AuthUsername AS [Auth Username],
AuthPassword AS [Auth Password],
IsDefaultInstance AS [Is Default Instance],
NetworkPort AS [Network Port],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active]
FROM DC.DatabaseInstance


GO
