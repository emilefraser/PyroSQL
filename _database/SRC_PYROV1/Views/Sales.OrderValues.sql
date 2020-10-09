SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

---------------------------------------------------------------------
-- Create Views and Functions
---------------------------------------------------------------------

CREATE VIEW Sales.OrderValues
  WITH SCHEMABINDING
AS

SELECT O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate;

GO
