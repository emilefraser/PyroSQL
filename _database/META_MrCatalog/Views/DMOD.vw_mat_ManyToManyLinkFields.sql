SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_mat_ManyToManyLinkFields] AS
SELECT l.ManyToManyLinkID AS [Many To Many Link ID]
	   ,l.LinkName AS [Link Name]
	   ,l.ManyToManyDataEntityID AS [M2M Data Entity ID]
	   ,de.DataEntityName  AS [M2M Data Entity Name]
	  ,lh.[LinkHubToManyToManyLinkID] AS [M2M Link ID]
      ,lh.[HubID] AS [Hub ID]
	  ,h.HubName AS [Hub Name]
      ,lh.[HubSortOrder] AS [Hub Sort Order]
	  ,f.LinkHubToManyToManyLinkFieldID AS [Link Hub M2M Link Field ID]
	  ,f.HubPKFieldID AS [Hub PK Field ID]
	  ,dcpk.FieldName AS [Hub PK Field Name]
	  ,dcpk.DataEntityName AS [Hub PK Data Entity Name]
	  ,f.ManyToManyTableFKFieldID  AS [M2M Table FK Field ID]
	  ,dcfk.FieldName AS [M2M Table FK Field Name]
	  ,dcfk.DataEntityName AS [M2M Table FK Data Entity Name]
  FROM [DMOD].[ManyToManyLink] l
		LEFT JOIN [DMOD].[LinkHubToManyToManyLink] lh
			ON l.ManyToManyLinkID = lh.ManyToManyLinkID
		LEFT JOIN [DMOD].[LinkHubToManyToManyLinkField] f
			ON f.LinkHubToManyToManyLinkID = lh.LinkHubToManyToManyLinkID
		LEFT JOIN [DC].[DataEntity] de
			ON de.DataEntityID = l.ManyToManyDataEntityID
		LEFT JOIN [DMOD].Hub h
			ON h.HubID = lh.HubID
		LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail dcpk
			ON dcpk.FieldID = f.HubPKFieldID
		LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail dcfk
			ON dcfk.FieldID = f.ManyToManyTableFKFieldID


--INSERT INTO [DMOD].[ManyToManyLink]
--		(LinkName, ManyToManyDataEntityID)
--		VALUES
--		('PKFKLink_Terminal_EventType_Direction_ClockHistory', 631)

--UPDATE  [DMOD].[ManyToManyLink] SET LinkName = 'Link_Terminal_EventType_Direction_ClockHistory'
	 

--INSERT INTO [DMOD].[LinkHubToManyToManyLink]
--		( ManyToManyLinkID, HubID, HubSortOrder)
--		VALUES
--		(2,    2 , 4)


--INSERT INTO [DMOD].LinkHubToManyToManyLinkField 
--		(LinkHubToManyToManyLinkID, HubPKFieldID, ManyToManyTableFKFieldID)
--		VALUES
--		(3, 9047  ,  9048 )

--SELECT * FROM DMOD.Hub
--INSERT INTO DMOD.HubBusinessKey (HubID, FieldSortOrder, BKFriendlyName)
--			VALUES (32, 1, '')

GO
