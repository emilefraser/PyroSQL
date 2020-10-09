SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW Sales.vw_OrdersByEmployee
AS
SELECT
	ord.[orderid] AS orderid_orders
,	ord.[custid]
,	ord.[empid]
,	ord.[orderdate]
,	ord.[requireddate]
,	ord.[shippeddate]
,	ord.[shipperid]
,	ord.[freight]
,	ord.[shipname]
,	ord.[shipaddress]
,	ord.[shipcity]
,	ord.[shipregion]
,	ord.[shippostalcode]
,	ord.[shipcountry]
,	orddet.productid
,	orddet.unitprice AS unitprice_sold
,	orddet.qty
,	lineitemamount = (orddet.qty * orddet.unitprice) - (orddet.discount)
,	orddet.discount
,	emp.titleofcourtesy + ' ' + emp.firstname + ' ' + emp.lastname + ' (' + emp.title + ')' AS Employee
,	emp.[address] + ', ' + emp.city + ', ' + emp.region + ', ' + emp.postalcode AS Address0
,	emp.[address] + ', ' + emp.city + ', ' + ISNULL(emp.region, 'Unknown') + ', ' + emp.postalcode AS Address_Plus
,	emp.[address] + ', ' + emp.city + ', ' + COALESCE(emp.region, 'Unknown') + ', ' + emp.postalcode AS Address_PlusCoalesce
,	CONCAT(emp.[address],', ', emp.city, ', ', ISNULL(emp.region, 'Unknown'), ', ', emp.postalcode) AS Address01_Concat
,	CONCAT_WS(', ' , emp.[address], emp.city, emp.region, emp.postalcode) AS Adress02_ConcatWS
FROM 
	[Sales].[Orders] AS ord
INNER JOIN 
	[Sales].[OrderDetails] AS orddet
	ON orddet.orderid = ord.orderid
INNER JOIN 
	HR.Employees AS emp
	ON emp.empid = ord.empid
GO
