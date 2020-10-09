SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [INTEGRATION].[vw_egress_DataDistributionBatchData] AS
SELECT [DataConcat]
      ,[DataDistributionBatchID]
  FROM [INTEGRATION].[DataDistributionBatchData]

GO
