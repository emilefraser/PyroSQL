SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW Sales.CustOrders
  WITH SCHEMABINDING
AS

SELECT
  O.custid, 
  DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE)) AS ordermonth,
  SUM(OD.qty) AS qty
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY custid, DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE));

GO
