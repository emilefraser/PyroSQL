SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW Sales.vw_OrderDetails
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
--,	orddet.orderid  AS orderid_orderdetail
,	orddet.productid
,	prod.productname
,	orddet.unitprice AS unitprice_sold
,	orddet.qty
,	lineitemamount = (orddet.qty * orddet.unitprice) - (orddet.discount)
,	orddet.discount
,	supplierid
,	prod.unitprice AS unitprice_current
,	prod.discontinued
,	prod.categoryid
,	cat.categoryname
,	cat.[description]
FROM 
	[Sales].[Orders] AS ord
INNER JOIN 
	[Sales].[OrderDetails] AS orddet
	ON orddet.orderid = ord.orderid
INNER JOIN 
	Production.Products AS prod
	ON prod.productid = orddet.productid
INNER JOIN 
	Production.Categories AS cat
	ON cat.categoryid = prod.categoryid
GO
