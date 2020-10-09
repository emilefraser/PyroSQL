SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [INTEGRATION].[vw_egress_DataDistributionBatch] AS
SELECT [DataDistributionBatchID]
      ,[CreatedDT]
      ,[DataEntityDDL]
  FROM [INTEGRATION].[DataDistributionBatch]

GO
