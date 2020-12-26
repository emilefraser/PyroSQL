USE AdventureWorks2016_EXT
GO
/********************************************************************************
*	SCENARIO 5 - Data import/export.
*	Create procedures that import JSON into tables or export relational data as JSON text.
********************************************************************************/

/********************************************************************************
*	STEP 5.1 - Create procedures for formatting table data as JSON text.
********************************************************************************/
GO
-- Returns information about person formatted as JSON
CREATE PROCEDURE
Person.PersonInfo_json(@PersonID int)
as begin
	SELECT PersonID,PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			JSON_QUERY(EmailAddresses, '$') AS EmailAddresses, JSON_QUERY(PhoneNumbers, '$') AS PhoneNumbers
	FROM Person.Person_json
	WHERE PersonID = @PersonID
	FOR JSON PATH
end
GO
-- Returns information about sales order formatted as JSON
CREATE PROCEDURE
Sales.SalesOrderExport_json(@SalesOrderID int)
as begin
	SELECT SalesOrderNumber, OrderDate, Status, ShipDate, AccountNumber, TotalDue,
		JSON_QUERY(Info, '$.ShippingInfo') ShippingInfo,
		JSON_QUERY(Info, '$.BillingInfo') BillingInfo,
		JSON_VALUE(Info, '$.SalesPerson.Name') SalesPerson,
		JSON_VALUE(Info, '$.ShippingInfo.City') City,
		JSON_VALUE(Info, '$.Customer.Name') Customer,
		JSON_QUERY(OrderItems, '$') OrderItems
	FROM Sales.SalesOrder_json
	WHERE SalesOrderID = @SalesOrderID
	FOR JSON PATH
END
GO

/********************************************************************************
*	STEP 5.2 - Create procedures for loading JSON data into the tables.
********************************************************************************/

GO
-- Insert JSON containing person fields that should be imported in Person table
CREATE PROCEDURE 
Person.PersonInsert_json(@Person nvarchar(max))
as begin
	INSERT INTO Person.Person_json (
			PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailPromotion,ModifiedDate)
	SELECT PersonType,NameStyle,Title,FirstName,MiddleName,LastName,Suffix,
			EmailPromotion,ModifiedDate
	FROM OPENJSON(@Person)
			WITH(
				PersonType nchar(2),
				NameStyle dbo.NameStyle,
				Title nvarchar(8),
				FirstName dbo.Name,
				MiddleName dbo.Name,
				LastName dbo.Name,
				Suffix nvarchar(10),
				EmailPromotion int,
				AdditionalContactInfo NVARCHAR(MAX),
				Demographics NVARCHAR(MAX),
				ModifiedDate datetime
			)	
END
GO

CREATE PROCEDURE 
Person.PersonUpdate_json(@Person nvarchar(max))
as begin
	UPDATE Person.Person_json
	SET PersonType = json.PersonType,
		NameStyle = json.NameStyle,
		Title = json.Title,
		FirstName = json.FirstName,
		MiddleName = json.MiddleName,
		LastName = json.LastName,
		Suffix = json.Suffix,
		EmailPromotion = json.EmailPromotion,
		AdditionalContactInfo = json.AdditionalContactInfo,
		Demographics = json.Demographics
	FROM OPENJSON(@Person)
			WITH(
				PersonID int,
				PersonType nchar(2),
				NameStyle dbo.NameStyle,
				Title nvarchar(8),
				FirstName dbo.Name,
				MiddleName dbo.Name,
				LastName dbo.Name,
				Suffix nvarchar(10),
				EmailPromotion int,
				AdditionalContactInfo NVARCHAR(MAX),
				Demographics NVARCHAR(MAX)
			) AS json
		WHERE Person_json.PersonID = json.PersonID
END
GO

CREATE PROCEDURE 
Sales.SalesOrderInsert_json(@SalesOrder nvarchar(max))
as begin
	INSERT INTO Sales.SalesOrder_json (SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,
								OnlineOrderFlag,PurchaseOrderNumber,AccountNumber,CustomerID,
								CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,Comment)
	SELECT SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,
			OnlineOrderFlag,PurchaseOrderNumber,AccountNumber,CustomerID,
			CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,Comment
	FROM OPENJSON(@SalesOrder)
			WITH(
					SalesOrderID int,
					RevisionNumber tinyint,
					OrderDate datetime,
					DueDate datetime,
					ShipDate datetime,
					Status tinyint,
					OnlineOrderFlag dbo.Flag,
					PurchaseOrderNumber dbo.OrderNumber ,
					AccountNumber dbo.AccountNumber,
					CustomerID int,
					CreditCardApprovalCode varchar(15),
					CurrencyRateID int,
					SubTotal money,
					TaxAmt money,
					Freight money,
					Comment nvarchar(128)
			)	
END
GO

CREATE PROCEDURE 
Sales.SalesOrderUpdate_json(@SalesOrder nvarchar(max))
as begin
	UPDATE Sales.SalesOrder_json
	SET RevisionNumber = json.RevisionNumber,
		OrderDate = json.OrderDate,
		DueDate = json.DueDate,
		ShipDate = json.ShipDate,
		Status = json.Status,
		OnlineOrderFlag = json.OnlineOrderFlag,
		PurchaseOrderNumber = json.PurchaseOrderNumber,
		AccountNumber = json.AccountNumber,
		CustomerID = json.CustomerID,
		CreditCardApprovalCode = json.CreditCardApprovalCode,
		SubTotal = json.SubTotal,
		TaxAmt = json.TaxAmt,
		Freight = json.Freight,
		Comment = json.Comment
	FROM OPENJSON(@SalesOrder)
			WITH(
					SalesOrderID int,
					RevisionNumber tinyint,
					OrderDate datetime,
					DueDate datetime,
					ShipDate datetime,
					Status tinyint,
					OnlineOrderFlag dbo.Flag,
					PurchaseOrderNumber dbo.OrderNumber ,
					AccountNumber dbo.AccountNumber,
					CustomerID int,
					CreditCardApprovalCode varchar(15),
					CurrencyRateID int,
					SubTotal money,
					TaxAmt money,
					Freight money,
					Comment nvarchar(128)
			) AS json
		WHERE Sales.SalesOrder_json.SalesOrderID = json.SalesOrderID
END
GO