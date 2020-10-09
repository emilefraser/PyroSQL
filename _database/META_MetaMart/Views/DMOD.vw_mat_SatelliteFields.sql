SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_SatelliteFields] AS
SELECT 
	  s.[HubID] AS [Hub ID]
	  ,h.HubName AS [Hub Name]
	  ,s.[SatelliteID]  AS [Satellite ID]
      ,[TransactionLinkID] AS [Transaction Link ID]
      ,[SatelliteDataEnityID] AS [Satellite Data Enity ID]
      ,[SatelliteName] AS [Satellite Name]
      ,vt.[SatelliteDataVelocityTypeID] AS [Satellite Data Velocity Type ID]
	  ,vt.SatelliteDataVelocityTypeCode AS [Satellite Data Velocity Type Code]
	  ,vt.SatelliteDataVelocityTypeName AS [Satellite Data Velocity Type Name]
      ,[IsDetailTransactionLinkSat] AS [Is Detail Transaction Link Satellite]
	  ,f.SatelliteFieldID AS [Satellite Field ID]
	  ,f.FieldID AS [Field ID]
	  ,f.IsActive AS [Is Active]
	  ,dc.DBColumnID AS [Sort Order]
	  ,dc.FieldName AS [Field Name]
	  ,dc.DataEntityName AS [Date Entity Name]
	  ,dc.DatabaseName AS [Database Name]
	  ,dc.SchemaName AS [Schema Name]
	  ,dc.ServerName AS [Server Name]
	  ,dc.SystemName AS [System Name]
  FROM [DMOD].[Satellite] s
  JOIN [DMOD].[SatelliteField] f
		ON f.SatelliteID = s.SatelliteID
  JOIN [DMOD].[Hub] h
		ON h.HubID = s.HubID
  JOIN [DMOD].[SatelliteDataVelocityType] vt
		ON vt.SatelliteDataVelocityTypeID = s.SatelliteDataVelocityTypeID
  JOIN [DC].vw_rpt_DatabaseFieldDetail dc
		ON dc.FieldID = f.FieldID

 

GO
