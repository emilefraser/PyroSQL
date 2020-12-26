USE AdventureWorks2016_EXT
GO
/********************************************************************************
*	SCENARIO 3 - Data querying and analysis.
*	Create procedures that encapsulate and query JSON data.
********************************************************************************/

-- Get SalesOrder and related information by ID.
CREATE PROCEDURE
Sales.SalesOrderInfo_json(@SalesOrderID int)
AS BEGIN
	SELECT SalesOrderNumber, OrderDate, Status, ShipDate, Status, AccountNumber, TotalDue,
		JSON_QUERY(Info, '$.ShippingInfo') ShippingInfo,
		JSON_QUERY(Info, '$.BillingInfo') BillingInfo,
		JSON_VALUE(Info, '$.SalesPerson.Name') SalesPerson,
		JSON_VALUE(Info, '$.ShippingInfo.City') City,
		JSON_VALUE(Info, '$.Customer.Name') Customer,
		JSON_QUERY(OrderItems, '$') OrderItems
	FROM Sales.SalesOrder_json
	WHERE SalesOrderID = @SalesOrderID
END
GO

---------------------------------------------------------------------------------------------------------
--	Equivalent stored procedure in normalized schema.
---------------------------------------------------------------------------------------------------------
CREATE PROCEDURE
Sales.SalesOrderInfoRel_json(@SalesOrderID int)
as begin
	SELECT SalesOrderNumber, OrderDate, ShipDate, Status, Sales.SalesOrder_json.AccountNumber, TotalDue,
		shipprovince.Name as [Shipping Province], 
		shipmethod.Name as [Shipping Method], 
		shipmethod.ShipRate as ShipRate,
		billaddr.AddressLine1 + COALESCE ( ', ' + shipaddr.AddressLine2, '') as [Billing Address],
		sp.FirstName + ' ' +  sp.LastName as [Sales Person],
		cust.FirstName + ' ' + cust.LastName as Customer	
	FROM Sales.SalesOrder_json
		JOIN Person.Address shipaddr
			ON Sales.SalesOrder_json.ShipToAddressID = shipaddr.AddressID
				LEFT JOIN Person.StateProvince shipprovince
					ON shipaddr.StateProvinceID = shipprovince.StateProvinceID
		JOIN Purchasing.ShipMethod shipmethod
			ON Sales.SalesOrder_json.ShipMethodID = shipmethod.ShipMethodID
		JOIN Person.Address billaddr
			ON Sales.SalesOrder_json.BillToAddressID = billaddr.AddressID
		LEFT JOIN Sales.SalesPerson
			ON Sales.SalesPerson.BusinessEntityID = Sales.SalesOrder_json.SalesPersonID
			LEFT JOIN Person.Person AS sp
				ON Sales.SalesPerson.BusinessEntityID = sp.BusinessEntityID
		LEFT JOIN Sales.Customer
			ON Sales.Customer.CustomerID = Sales.SalesOrder_json.CustomerID
			LEFT JOIN Person.Person AS cust
				ON Sales.Customer.CustomerID = cust.BusinessEntityID
	WHERE Sales.SalesOrder_json.SalesOrderID = @SalesOrderID
end
GO

-- Find person rows using a list of identifiers
CREATE PROCEDURE
Person.PersonList_json(@PersonIds nvarchar(100))
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailAddresses, PhoneNumbers
	FROM Person.Person_json
		JOIN OPENJSON(@PersonIds)
			ON PersonID = value
end
GO

-- Find SalesOrder rows using a list of identifiers
CREATE PROCEDURE
Sales.SalesOrderList_json(@SalesOrderIds nvarchar(100))
as begin
	SELECT SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,
			OnlineOrderFlag,PurchaseOrderNumber,AccountNumber,CustomerID,
			CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,Comment
	FROM Sales.SalesOrder_json
		JOIN OPENJSON(@SalesOrderIds)
			ON SalesOrderID = value
end

GO
-- Filter sales orders by customer name.
CREATE PROCEDURE
Sales.SalesOrderSearchByCustomer_json (@customer nvarchar(50))
as begin
	SELECT SalesOrderNumber, OrderDate, Status, AccountNumber,
		JSON_QUERY(Info, '$.ShippingInfo') ShippingInfo,
		JSON_QUERY(Info, '$.BillingInfo') BillingInfo,
		JSON_VALUE(Info, '$.SalesPerson.Name') SalesPerson,
		JSON_VALUE(Info, '$.ShippingInfo.City') City,
		JSON_VALUE(Info, '$.Customer.Name') Customer,
		OrderItems
	FROM Sales.SalesOrder_json
	WHERE JSON_VALUE(Info, '$.Customer.Name') = @customer
END
GO

-- Filter person rows by phone number.
CREATE PROCEDURE
Person.PersonSearchByPhone_json(@PhoneNumber nvarchar(100))
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailAddresses, PhoneNumbers
	FROM Person.Person_json
		CROSS APPLY OPENJSON(PhoneNumbers)
			WITH (PhoneNumber nvarchar(100))
	WHERE @PhoneNumber = PhoneNumber
end
GO

-- Filter person rows by phone number and type.
CREATE PROCEDURE
Person.PersonSearchByPhoneNumberAndType_json(@PhoneNumber nvarchar(100), @PhoneNumberType nvarchar(20))
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailAddresses, PhoneNumbers
	FROM Person.Person_json
		CROSS APPLY OPENJSON(PhoneNumbers)
			WITH (PhoneNumber nvarchar(100), PhoneNumberType nvarchar(20))
	WHERE PhoneNumber = @PhoneNumber
	AND PhoneNumberType = @PhoneNumberType
end
GO

-- Filter sales orders by sales reason.
CREATE PROCEDURE
Sales.SalesOrderSearchByReason_json (@reason nvarchar(50))
as begin
	SELECT SalesOrderNumber, OrderDate, SalesReasons
	FROM Sales.SalesOrder_json
		CROSS APPLY OPENJSON (SalesReasons)
	WHERE value = @reason
end
GO

-- Filter person rows by email.
CREATE PROCEDURE
Person.PersonSearchByEmail_json(@Email nvarchar(100))
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailAddresses, PhoneNumbers
	FROM Person.Person_json
		CROSS APPLY OPENJSON(EmailAddresses)
	WHERE @Email = value
end
GO
---------------------------------------------------------------------------------
--	Reporting.
---------------------------------------------------------------------------------

-- List of customers, their statuses, and sales order totals
-- Filtered by city and territory
CREATE PROCEDURE
Sales.SalesOrdersPerCustomerAndStatusReport_json(@city nvarchar(50), @territoryid int)
AS BEGIN
	SELECT JSON_VALUE(Info, '$.Customer.Name') AS Customer, Status, SUM(SubTotal) AS Total
	FROM Sales.SalesOrder_json
	WHERE TerritoryID = @territoryid
	AND JSON_VALUE(Info, '$.ShippingInfo.City') = @city
	AND OrderDate > '1/1/2015'
	GROUP BY JSON_VALUE(Info, '$.Customer.Name'), Status
	HAVING SUM(SubTotal) > 1000
END
GO

-- Number of sales orders grouped by sales reasons filtered by city
CREATE PROCEDURE
Sales.SalesOrdersBySalesReasonReport_json(@city nvarchar(50))
AS BEGIN
	SELECT value, COUNT(SalesOrderNumber) AS NumberOfOrders
	FROM Sales.SalesOrder_json 
		CROSS APPLY
			OPENJSON (SalesReasons)
	WHERE JSON_VALUE(Info, '$.ShippingInfo.City') = @city 
	GROUP BY value
END
GO
