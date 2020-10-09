SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_mat_Satellite]
AS
SELECT
s.SatelliteID AS [Satellite ID],
s.HubID AS [Hub ID],
s.TransactionLinkID AS [Transaction Link ID],
s.SatelliteDataEnityID AS [Satellite Data Entity ID],
s.SatelliteName AS [Satellite Name],
s.SatelliteDataVelocityTypeID AS [Satellite Data Velocity Type ID],
sdvt.SatelliteDataVelocityTypeCode AS [Satellite Data Velocity Type Code],
sdvt.SatelliteDataVelocityTypeName AS [Satellite Data Velocity Type Name],
s.IsDetailTransactionLinkSat AS [Is Detail Transaction Link Sat],
s.CreatedDT AS [Created Date],
s.UpdatedDT AS [Updated Date],
s.IsActive AS [Is Active]
FROM DMOD.Satellite s
LEFT JOIN DMOD.SatelliteDataVelocityType sdvt
ON s.SatelliteDataVelocityTypeID = sdvt.SatelliteDataVelocityTypeID

GO
