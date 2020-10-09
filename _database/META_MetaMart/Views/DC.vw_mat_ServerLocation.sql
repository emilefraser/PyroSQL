SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DC].[vw_mat_ServerLocation]
AS
SELECT
ServerLocationID AS [Server Location ID],
ServerLocationCode AS [Server Location Code],
ServerLocationName AS [Server Location Name], 
IsCloudLocation AS [Is Cloud Location],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active]

FROM [DC].[ServerLocation]

GO
