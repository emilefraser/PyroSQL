SELECT a.* FROM  
OPENROWSET (BULK N'C:\Users\emile.fraser\Documents\CoreBI\3_SQL\_Tools_\bcp\Andre.csv'/*, FORMATFILE =   
    'D:\format_no_collation.txt', CODEPAGE = '65001'*/) AS a;  


	select *
into #T
from openrowset('MSDASQL', 'Driver={Microsoft Text Driver (*.txt; *.csv)};
DefaultDir={path to file, not including file name};Extensions=csv;',
'select * from CSV1_4_Cols.csv') Test;

select *
from #T;

Microsoft.ACE.OLEDB.12.0

SELECT *

FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',

'Text;Database=C:\Users\emile.fraser\Documents\CoreBI\3_SQL\_Tools_\bcp\;HDR=YES',

'SELECT * FROM Andre.csv')


SELECT * 

FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',

'Text;Database=C:\Users\emile.fraser\Documents\CoreBI\3_SQL\_Tools_\bcp\;',

'SELECT * FROM Andre.csv')

SELECT * FROM xx_test

SELECT * 
INTO xx_test
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',

'Text;Database=E:\CoreBI\GoogleDrive\1_RawData\ShopperTrak\;HDR=YES;CharacterSet=65001;',

'SELECT * FROM Andre.csv')


SELECT * FROM  xx_test

DROP TABLE xx_test





E:\CoreBI\GoogleDrive\1_RawData\ShopperTrak
select * from
OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Text;Database=C:\TEST\;', 
'SELECT * FROM ABC.csv')



SELECT * FROM OPENROWSET('MSDASQL',

'Driver={Microsoft Text Driver (*.txt; *.csv)};

DefaultDir=C:\Users\emile.fraser\Documents\CoreBI\3_SQL\_Tools_\bcp\;',

'SELECT * FROM Andre.csv')


SELECT * INTO XLImport3 FROM OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0',  
'Data Source=C:\test\xltest.xls;Extended Properties=Excel 8.0')...[Customers$]  
 
SELECT * INTO XLImport4 FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',  
'Excel 8.0;Database=C:\test\xltest.xls', [Customers$])  
 
SELECT * INTO XLImport5 FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',  
'Excel 8.0;Database=C:\test\xltest.xls', 'SELECT * FROM [Customers$]'


SQLOLEDB



Execute the following Microsoft SQL Server T-SQL script to demonstrate data import from .csv flat file using OPENROWSET applying 2 different providers and applying BULK INSERT. 

USE AdventureWorks2008;

 

EXEC sp_configure

GO

-- [Ad Hoc Distributed Queries] run_value should be 1

 

SELECT * FROM OPENROWSET('MSDASQL',

'Driver={Microsoft Text Driver (*.txt; *.csv)};

DefaultDir=F:\data\export\csv\;',

'SELECT * FROM Top10.csv')

GO

------------

 

--Using a different provider

SELECT *

FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',

'Text;Database=F:\data\export\csv\;HDR=YES',

'SELECT * FROM Top10.csv')

GO

------------
 
-- T-SQL import local csv file with BULK INSERT
BULK INSERT InventoryDB.dbo.InvStage
   FROM 'C:\data\importstage\ukinventory.csv'
   WITH 
      (
        FIELDTERMINATOR = ',', 
        ROWTERMINATOR = '\n' 
      )

------------