SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================
-- Create Customer View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_Customer] AS (
SELECT
[CustomerID],
[CustomerName]
FROM [ASSESS].[Customer]
)

GO
