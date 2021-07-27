INSERT INTO B2BSalesPerson (Customer, SalesPerson, Company, Business, Category)
SELECT cp.Accounts, cp.Sales_Rep, 'P', cp.[Name], cp.CAT
FROM [Core_DW].[dbo].B2BSalesPerson_CP_Kelly AS cp
WHERE NOT EXISTS
(
	SELECT DISTINCT SalesPerson  FROM 
	[Core_DW].[dbo].B2BSalesPerson AS b2b
	WHERE b2b.Company = 'P'
	AND cp.Accounts = b2b.Customer
)



UPDATE sp
SET sp.Business =  b2bk.[Name]
, sp.[Category] = b2bk.[CAT]
, sp.SalesPerson = b2bk.Sales_Rep
FROM [Core_DW].[dbo].B2BSalesPerson AS sp
INNER JOIN [Core_DW].[dbo].B2BSalesPerson_CP_Kelly AS b2bk
ON
	 sp.Company = 'P'
	AND sp.Customer = b2bk.Accounts



INSERT INTO B2BSalesPerson (Customer, SalesPerson, Company, Business)
SELECT ci.Customer, ci.Update_Rep, 'I', ci.[CustomerName]
FROM [Core_DW].[dbo].B2BSalesPerson_CI_Kelly AS ci
WHERE NOT EXISTS
(
	SELECT * FROM 
	[Core_DW].[dbo].B2BSalesPerson AS b2b
	WHERE b2b.Company = 'I'
	AND ci.Customer = b2b.Customer
)



UPDATE sp
SET sp.Business =  bik.[CustomerName]
, sp.SalesPerson = bik.Update_Rep
FROM [Core_DW].[dbo].B2BSalesPerson AS sp
INNER JOIN [Core_DW].[dbo].B2BSalesPerson_CI_Kelly AS bik
ON
	 sp.Company = 'I'
	AND sp.Customer = bik.Customer


UPDATE b2b
SET b2b.Business = nd6.CoreGroupName
FROM [Core_DW].[dbo].[B2BSalesPerson] AS b2b
INNER JOIN ND6_Category AS nd6
ON b2b.Customer = nd6.Customer
WHERE b2b.Business IS NULL
AND nd6.CoreGroupName IS NOT NULL


UPDATE b2b
SET b2b.Business = va.CustName
FROM [Core_DW].[dbo].[B2BSalesPerson] AS b2b
INNER JOIN v_ArCustomer AS va
ON b2b.Customer = va.Customer
WHERE b2b.Business IS NULL
AND va.CustName IS NOT NULL

UPDATE sp
SET SalesPerson	 = 'Branden'
FROM [Core_DW].[dbo].[B2BSalesPerson] AS sp
WHERE sp.[SalesPerson]	= 'Branden Hart'


SELECT * FROM [dbo].[InvMasterHierarchy] imh	
WHERE [imh].[Stock Code] = '_FAC'


SELECT * FROM [dbo].[InvMaster_2] imh	
WHERE [imh].[StockCode] = '_FAC'


SELECT * FROM [dbo].[InvProductClass_2]
WHERE [ProdClass] = '_FAC'


SELECT * FROM [dbo].[InvProductClass_2]
WHERE [ProdClass] = '_INF'



