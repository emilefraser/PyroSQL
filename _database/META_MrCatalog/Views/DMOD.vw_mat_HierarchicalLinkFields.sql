SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_HierarchicalLinkFields] AS
SELECT [HierarchicalLinkID] AS [Hierarchical Link ID]
      ,[HubID] AS [Hub ID]
      ,[HierarchicalLinkName] AS [Hierarchical Link Name]
      ,[PKFieldID] AS [Primary Key Field ID]
	  ,pkf.FieldName AS [Primary Key Field Name]
	  ,pkde.DataEntityName AS [Primary Key Data Entity Name]
      ,[ParentFieldID] AS [Parent Field ID]
	  ,pf.FieldName AS [Parent Field Name] 
	  ,pde.DataEntityName AS [Parent Data Entity Name]
      ,link.IsActive
FROM [DMOD].[HierarchicalLink] link
JOIN [DC].[Field] pkf
	ON pkf.FieldID = link.PKFieldID
JOIN [DC].[DataEntity] pkde
	ON pkde.DataEntityID = pkf.DataEntityID
JOIN [DC].[Field] pf
	ON pf.FieldID = link.ParentFieldID
JOIN [DC].[DataEntity] pde
	ON pde.DataEntityID = pf.DataEntityID

GO
