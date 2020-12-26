USE AdventureWorks2016_EXT
GO

/********************************************************************************
*	Basic demo queries.
********************************************************************************/

-- Getting started
DECLARE @json NVARCHAR(4000)
SET @json = 
N'{
    "info":{  
      "type":1,
      "address":{  
        "town":"Bristol",
        "county":"Avon",
        "country":"England"
      },
      "tags":["Sport", "Water polo"]
   },
   "type":"Basic"
}'

-- Using JSON_VALUE function
SELECT
  JSON_VALUE(@json, '$.type') a,
  JSON_VALUE(@json, '$.info.type') b,
  JSON_VALUE(@json, '$.info.address.town') c,
  JSON_VALUE(@json, '$.info.tags[0]') d

-- Using ISJSON function
SELECT
  ISJSON(@json) AS json1,
  ISJSON(JSON_QUERY(@json, '$.info')) AS json2,
  ISJSON(JSON_VALUE(@json, '$.info.type')) AS not_json

-- Using JSON_QUERY function
SELECT
  JSON_QUERY(@json, '$') as [object],
  JSON_QUERY(@json, '$.info') as info,
  JSON_QUERY(@json, '$.info.address') as address,
  JSON_QUERY(@json, '$.info.tags') as tags

-- Using OPENJSON function with default schema
SELECT [key] as property, value
FROM OPENJSON(@json, '$.info.address')

SELECT [key] as i, value
FROM OPENJSON(@json, '$.info.tags')

-- Using OPENJSON function with explicitly defined schema
SELECT *
FROM OPENJSON(@json, '$.info')
WITH ( type int,
       town nvarchar(50) '$.address.town',
       country nvarchar(50) '$.address.country'
     )
GO


/********************************************************************************
*	Query examples on tables with JSON columns.
*	Prerequisite: Execute scripts 1-5 that populate data
*	and create views, procedures and indexes.
********************************************************************************/

-- Basic example with:
--	1. one standard table column,
--	2. one scalar value extracted from JSON column (sales person name) using JSON_VALUE, and
--	3. one JSON fragment (all customer information) using JSON_QUERY function.
SELECT SalesOrderNumber,
	JSON_VALUE(Info, '$.SalesPerson.Name') as [Sales Person],
	JSON_QUERY(Info, '$.Customer')	as Customer
FROM Sales.SalesOrder_json

-- Query that returns several values from different properties in JSON column.
SELECT SalesOrderNumber, OrderDate, ShipDate, Status, AccountNumber, TotalDue,
	JSON_VALUE(Info, '$.ShippingInfo.Province') as [Shipping Province], 
	JSON_VALUE(Info, '$.ShippingInfo.Method') as [Shipping Method], 
	JSON_VALUE(Info, '$.ShippingInfo.ShipRate') as ShipRate,
	JSON_VALUE(Info, '$.BillingInfo.Address') as [Billing Address],
	JSON_VALUE(Info, '$.SalesPerson.Name') as [Sales Person],
	JSON_VALUE(Info, '$.Customer.Name')	as Customer
FROM Sales.SalesOrder_json
WHERE JSON_VALUE(Info, '$.Customer.Name') = 'Edwin Shen'

-- Equivalent query that uses OPENJSON instead of several JSON_VALUE functions:
SELECT SalesOrderNumber, OrderDate, ShipDate, Status, AccountNumber, TotalDue,
	[Shipping Province], [Shipping Method], ShipRate, [Sales Person], Customer
FROM Sales.SalesOrder_json
	CROSS APPLY OPENJSON(Info)
		WITH ([Shipping Province] nvarchar(100) '$.ShippingInfo.Province',
				[Shipping Method] nvarchar(20) '$.ShippingInfo.Method',
				ShipRate float '$.ShippingInfo.ShipRate',
				[Billing Address] nvarchar(100) '$.BillingInfo.Address',
				[Sales Person] nvarchar(100) '$.SalesPerson.Name',
				Customer nvarchar(4000) '$.Customer.Name') AS SalesOrderInfo
WHERE Customer = 'Edwin Shen'
GO

-- Executing stored procedures

-- Find person rows by ids 1,4,7, and 12.
EXEC Person.PersonList_json '[1,4,7,12]'

-- Return information about person with id 4
EXEC Person.PersonInfo_json 4

-- Find all person rows with specified email
EXEC Person.PersonSearchByEmail_json 'ken0@adventure-works.com'

-- Find all person rows with specified phone number
EXEC Person.PersonSearchByPhone_json '330-555-2568'

-- Get information about sales order with id 43659
EXEC Sales.SalesOrderInfo_json 43659

-- Export information about sales order with id 43659 as JSON text
EXEC Sales.SalesOrderExport_json 43659

-- Find sales orders with ids 43659,43660,43661,43662, and 43663.
EXEC Sales.SalesOrderList_json '[43659,43660,43661,43662,43663]'

-- Find all sales orders with specified sales price.
EXEC Sales.SalesOrderSearchByReason_json 'Price'

/*
Note: These procedures require Full-Text Search indexes.
Uncomment these lines only if you have FTS installed!

-- Find all sales orders with specified sales price using Full-Text Search
-- Note: skip this query if you don't have FTS.
EXEC Sales.SalesOrderSearchByReasonQuery_json 'Price'

-- Find all sales orders with specified sales prices using Full-Text Search
-- Note: skip this query if you don't have FTS.
EXEC Sales.SalesOrderSearchByReasonQuery_json 'Price OR Quality'

*/

-- Find all sales orders with specified customer.
-- Include Actual execution plan.
EXEC Sales.SalesOrderSearchByCustomer_json 'Joe Rana'
-- Note: this query uses index on JSON property.

GO

-- Querying views
-- Returns number of orders for specified customer.
-- Note: This view uses JSON_VALUE to fetch data from JSON
SELECT count(*) FROM Sales.vwSalesOrderInfo_json
WHERE Customer = 'Edwin Shen'

-- Returns number of orders for specified customer.
-- Note: This view uses OPENJSON to fetch data from JSON
SELECT count(*) FROM Sales.vwSalesOrderInfo2_json
WHERE Customer = 'Edwin Shen'

GO

-- Import/export data
-- Example 1.1: Format SalesOrder as JSON result
SELECT SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,
		OnlineOrderFlag,PurchaseOrderNumber,AccountNumber,CustomerID,
		CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,Comment
FROM Sales.SalesOrder_json
WHERE SalesOrderID = 43659
FOR JSON PATH

-- Example 1.2: Format SalesOrder as JSON result using stored procedure.
EXEC Sales.SalesOrderExport_json 43659

GO

-- Example 2: Insert SalesOrder with id 1 formatted as JSON string
-- Note:  We are using fields from a sales order 43659 exported in previous step.
-- Only SalesOrderID key is changed from 43659 to 1 in order to have unique primary key.
declare @json nvarchar(max) = '{"SalesOrderID":1,"RevisionNumber":27,"OrderDate":"2005-07-01T00:00:00","DueDate":"2005-07-13T00:00:00","ShipDate":"2005-07-08T00:00:00","Status":5,"OnlineOrderFlag":false,"PurchaseOrderNumber":"PO522145787","AccountNumber":"10-4020-000676","CreditCardApprovalCode":"105041Vi84182","SubTotal":20565.6206,"TaxAmt":1971.5149,"Freight":616.0984,"CustomerID":29825}'
EXEC Sales.SalesOrderInsert_json @json

-- Verify that it is inserted and compare results with original sales order (43659):
EXEC Sales.SalesOrderList_json '[1,43659]'

GO

-- Example 3: Update SalesOrder with id 1 formatted as JSON string
-- Note: All fields are same except RevisionNumber that is increased to 28:
declare @json nvarchar(max) = '{"SalesOrderID":1,"RevisionNumber":28,"OrderDate":"2005-07-01T00:00:00","DueDate":"2005-07-13T00:00:00","ShipDate":"2005-07-08T00:00:00","Status":5,"OnlineOrderFlag":false,"PurchaseOrderNumber":"PO522145787","AccountNumber":"10-4020-000676","CreditCardApprovalCode":"105041Vi84182","SubTotal":20565.6206,"TaxAmt":1971.5149,"Freight":616.0984,"CustomerID":29825}'
EXEC Sales.SalesOrderUpdate_json @json

-- Verify that revision number is updated (compare it with original row (43659)):
EXEC Sales.SalesOrderList_json '[1,43659]'

