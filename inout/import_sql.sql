USE AdventureWorks2008

EXEC sp_configure
GO
--[Ad Hoc Distributed Queries] run_value should be 1

 
SELECT 
	* 
FROM 
	OPENROWSET('MSDASQL', 'Driver={Microsoft Text Driver (*.txt; *.csv)}; DefaultDir=C:\test\;', 'SELECT * FROM TransactionCode.csv')

GO

------------

 

--Using a different provider

SELECT *

FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',

'Text;Database=F:\data\export\csv\;HDR=YES',

'SELECT * FROM Top10.csv')

GO

------------
DROP TABLE IF EXISTS MASTEROFALL.dbo.TransactionCode
CREATE TABLE MASTEROFALL.dbo.TransactionCode (
	TransactionCodeDesc VARCHAR(200),
	TransctionCode VARCHAR(50), 
	TransactionDesc VARCHAR(150)
)

-- T-SQL import local csv file with BULK INSERT
BULK INSERT MASTEROFALL.dbo.TransactionCode
   FROM 'C:\test\TransactionCode.csv'
   WITH
      (
		FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n'
      )

------------




select 
*
from openrowset('MSDASQL'
,'Driver={Microsoft Access Text Driver (*.txt, *.csv)}'
,'select * from C:\test\TransactionCode.csv')

OR

select
*
from openrowset('MSDASQL'
,'Driver={Microsoft Access Text Driver (*.txt, *.csv)}; 
DBQ=C:\test\' 
,'select * from "TransactionCode.csv"') T

OR

select
[hour],
UserID,
[ReportLaunch]
from openrowset('MSDASQL'
 ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)}; 
 DefaultDir=C:\blog\' 
 ,'select * from "input.CSV"') T