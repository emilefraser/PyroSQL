SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW Sales.EmpOrders  
  WITH SCHEMABINDING  
AS  
  
SELECT  
  O.empid,
  DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE)) AS ordermonth,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - discount))  
       AS NUMERIC(12, 2)) AS val,
  COUNT(*) AS numorders  
FROM Sales.Orders AS O  
  JOIN Sales.OrderDetails AS OD  
    ON OD.orderid = O.orderid  
GROUP BY empid, DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE));

GO
