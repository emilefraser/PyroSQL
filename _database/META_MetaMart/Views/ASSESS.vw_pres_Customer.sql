SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================
-- Create Customer View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_Customer] AS (
SELECT
[CustomerID] AS [Customer ID],
[CustomerName] AS [Customer Name]
FROM [ASSESS].[vw_rpt_Customer]
)

GO
