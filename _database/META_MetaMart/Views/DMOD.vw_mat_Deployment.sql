SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
Create view [DMOD].[vw_mat_Deployment]
AS Select H.HubName , H.IsReferenceHub , VM.LinkName , VM.HierarchicalLinkName
From [DMOD].[Hub] H , [DMOD].[vw_mat_ValidateModel] VM 


GO
