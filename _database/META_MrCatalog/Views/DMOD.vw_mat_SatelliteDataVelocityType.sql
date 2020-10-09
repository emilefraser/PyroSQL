SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_mat_SatelliteDataVelocityType]
AS
SELECT
SatelliteDataVelocityTypeID AS [Satellite Data Velocity Type ID],
SatelliteDataVelocityTypeCode AS [Satellite Data Velocity Type Code],
SatelliteDataVelocityTypeName AS [Satellite Data Velocity Type Name]
FROM DMOD.SatelliteDataVelocityType

GO
