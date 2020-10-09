SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [DC].[vw_mat_Server] AS
SELECT 
ServerID AS [Server ID],
ServerName AS [Server Name],
ServerLocation AS [Server Location],
PublicIP AS [Public IP],
LocalIP AS [Local IP],
UserID AS [User ID],
AccessInstructions AS [Access Instructions],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active],
ServerTypeID AS [Server Type ID]
FROM DC.Server


GO
