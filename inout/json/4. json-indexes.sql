USE AdventureWorks2016_EXT
GO
/********************************************************************************
*	SCENARIO 4 - Indexing JSON data.
*	Create indexes on JSON columns.
********************************************************************************/

/********************************************************************************
*	Problem - following queries use full table scan since there is no additional filter:
EXEC Sales.SalesOrderSearchByCustomer_json 'Joe Rana'
EXEC Person.PersonSearchByEmail_json 'ken0@adventure-works.com'
EXEC Sales.SalesOrderSearchByReason_json 'Price'
*	
********************************************************************************/

/********************************************************************************
*	STEP S3.1 - Indexing JSON path using B-tree index.
*	Note: 
*	Warning! The maximum key length for a non-clustered index is 1700 bytes. The index 'idx_SalesOrder_json_CustomerName' has maximum length of 8000 bytes. For some combination of large values, the insert/update operation will fail.
*	This is expected warning because JSON_VALUE returns up to 8000 bytes. If indexed values are less than 1700 bytes there will be no error.
*	DO NOT CREATE INDEX ON A PROPERTY THAT MIGHT RETURN MORE THAN 1700 BYTES.  
********************************************************************************/

-- Create nonclustered JSON index on property $.Customer.Name in Info JSON column.
ALTER TABLE Sales.SalesOrder_json
	ADD vCustomerName AS JSON_VALUE(Info, '$.Customer.Name')
CREATE INDEX idx_SalesOrder_json_CustomerName
	ON Sales.SalesOrder_json(vCustomerName)
go

/********************************************************************************
*	Following query uses index:
EXEC Sales.SalesOrderSearchByCustomer_json 'Joe Rana'
*	
********************************************************************************/

/********************************************************************************
*	STEP S3.2 - Indexing JSON array element using full-text search index.
*	NOTE - Full-Text search component must be installed! Skip this example if you don't have FTS. 
********************************************************************************/

-- Create full text catalog for JSON data
CREATE FULLTEXT CATALOG jsonFullTextCatalog;
GO

-- Create full text index on SalesReason column.
CREATE FULLTEXT INDEX ON Sales.SalesOrder_json(SalesReasons)
	KEY INDEX PK_SalesOrder__json_SalesOrderID
	ON jsonFullTextCatalog;
GO

-- Create full text index on EmaillAdresses column.
CREATE FULLTEXT INDEX ON Person.Person_json(EmailAddresses)
	KEY INDEX PK_Person_json_PersonID
	ON jsonFullTextCatalog;
GO

-- Create procedure that search person rows by email using FTS
CREATE PROCEDURE
Person.PersonSearchByEmailAddressQuery_json (@EmailAddressQuery nvarchar(250))
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailAddresses, PhoneNumbers
	FROM Person.Person_json
	WHERE CONTAINS(EmailAddresses, @EmailAddressQuery)
end
GO

-- Create procedure that search sales orders by sales reasons using FTS
CREATE PROCEDURE
Sales.SalesOrderSearchByReasonQuery_json (@reason nvarchar(50))
as begin
	SELECT SalesOrderNumber, OrderDate, SalesReasons
	FROM Sales.SalesOrder_json
	WHERE CONTAINS(SalesReasons, @reason)
end
GO

/********************************************************************************
*	Following queries use full-text indexes:
EXEC Person.PersonSearchByEmailAddressQuery_json 'ken0@adventure-works.com'
EXEC Sales.SalesOrderSearchByReasonQuery_json 'Price'
EXEC Sales.SalesOrderSearchByReasonQuery_json 'Price OR Quality'
*	
********************************************************************************/