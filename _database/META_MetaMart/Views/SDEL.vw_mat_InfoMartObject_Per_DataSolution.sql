SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [SDEL].[vw_mat_InfoMartObject_Per_DataSolution] AS
SELECT  pr.ProjectID AS [Project ID]
		,pr.ProjectName AS [Project Name]
		,ds.DataSolutionID AS [Data SolutionID]
		,ds.DataSolutionName AS [Data SolutionName]
		,ds.DeliveryStatus AS [Delivery Status]
		,obj.InfoMartObjectID AS [InfoMart Object ID]
		,obj.InfoMartObjectName AS [InfoMart Object Name]
		,obj.DeliveryStatus AS [InfoMart Object Status]
		,obj.[Priority] AS [Priority]

FROM SDEL.Project pr
	LEFT JOIN SDEL.DataSolution_Per_Project ds_pr
		ON pr.ProjectID = ds_pr.ProjectID
			AND pr.IsActive = 1
	LEFT JOIN SDEL.DataSolution ds
		ON ds.DataSolutionID = ds_pr.DataSolutionID
			AND ds.IsActive = 1
	LEFT JOIN SDEL.InfoMartObject_Per_DataSolution obj_ds
		ON obj_ds.DataSolutionID = ds.DataSolutionID
	LEFT JOIN SDEL.InfoMartObject obj
		ON obj.InfoMartObjectID = obj_ds.InfoMartObectID
			AND obj.IsActive = 1

GO
