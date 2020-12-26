USE AdventureWorks2016_EXT
GO
/********************************************************************************
*	Scenario 2. - Views.
*	Create views on top of de-normalized JSON data in the tables.
********************************************************************************/

GO
-- View that "joins" SalesOrder with related OrderItems stored as an array in JSON column.
CREATE VIEW Sales.vwSalesOrderItems_json
AS
SELECT SalesOrderID, SalesOrderNumber, OrderDate,
	CarrierTrackingNumber, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal, ProductNumber, Name
FROM Sales.SalesOrder_json
	CROSS APPLY
		OPENJSON (OrderItems)
			WITH (	CarrierTrackingNumber NVARCHAR(20),
				OrderQty int '$.Item.Qty',
				UnitPrice float '$.Item.Price',
				UnitPriceDiscount float '$.Item.Discount',
				LineTotal float '$.Item.Total',
				ProductNumber NVARCHAR(20) '$.Product.Number',
				Name NVARCHAR(50) '$.Product.Name'
				)

GO
-- View that encapsulates JSON_VALUE and JSON_QUERY functions.
CREATE VIEW Sales.vwSalesOrderInfo_json AS
SELECT SalesOrderNumber,
	OrderDate, ShipDate, Status, AccountNumber, TotalDue,
	JSON_VALUE(Info, '$.ShippingInfo.Province') as [Shipping Province], 
	JSON_VALUE(Info, '$.ShippingInfo.Method') as [Shipping Method], 
	JSON_VALUE(Info, '$.ShippingInfo.ShipRate') as ShipRate,
	JSON_VALUE(Info, '$.BillingInfo.Address') as [Billing Address],
	JSON_VALUE(Info, '$.SalesPerson.Name') as [Sales Person],
	JSON_VALUE(Info, '$.Customer.Name')	as Customer
FROM Sales.SalesOrder_json

GO
-- Equivalent view that uses OPENJSON with strong types.
CREATE VIEW Sales.vwSalesOrderInfo2_json AS
SELECT SalesOrderNumber, OrderDate, ShipDate, Status, AccountNumber, TotalDue,
	[Shipping Province], [Shipping Method], ShipRate, [Sales Person], Customer
FROM Sales.SalesOrder_json
	CROSS APPLY OPENJSON(Info)
		WITH (	[Shipping Province] nvarchar(100) '$.ShippingInfo.Province',
				[Shipping Method] nvarchar(20) '$.ShippingInfo.Method',
				ShipRate float '$.ShippingInfo.ShipRate',
				[Billing Address] nvarchar(100) '$.BillingInfo.Address',
				[Sales Person] nvarchar(100) '$.SalesPerson.Name',
				Customer nvarchar(4000) '$.Customer.Name') AS SlaesOrderInfo
GO

-- Equivalent view created on the fully normalized structure:
CREATE VIEW Sales.vwSalesOrderInfoRel_json AS
SELECT SalesOrderNumber, OrderDate, ShipDate, Status, Sales.SalesOrderHeader.AccountNumber, TotalDue,
	shipprovince.Name as [Shipping Province], 
	shipmethod.Name as [Shipping Method], 
	shipmethod.ShipRate as ShipRate,
	billaddr.AddressLine1 + COALESCE ( ', ' + shipaddr.AddressLine2, '') as [Billing Address],
	sp.FirstName + ' ' +  sp.LastName as [Sales Person],
	cust.FirstName + ' ' + cust.LastName as Customer	
FROM Sales.SalesOrderHeader
	JOIN Person.Address shipaddr
		ON Sales.SalesOrderHeader.ShipToAddressID = shipaddr.AddressID
			LEFT JOIN Person.StateProvince shipprovince
				ON shipaddr.StateProvinceID = shipprovince.StateProvinceID
	JOIN Purchasing.ShipMethod shipmethod
		ON Sales.SalesOrderHeader.ShipMethodID = shipmethod.ShipMethodID
	JOIN Person.Address billaddr
		ON Sales.SalesOrderHeader.BillToAddressID = billaddr.AddressID
	LEFT JOIN Sales.SalesPerson
		ON Sales.SalesPerson.BusinessEntityID = Sales.SalesOrderHeader.SalesPersonID
		LEFT JOIN Person.Person AS sp
			ON Sales.SalesPerson.BusinessEntityID = sp.BusinessEntityID
	LEFT JOIN Sales.Customer
		ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
		LEFT JOIN Person.Person AS cust
			ON Sales.Customer.CustomerID = cust.BusinessEntityID
GO
