 
create table dbo.personlist (
	[name] varchar(20),
	[gender] varchar(10),
	[age] int,
	[city] varchar(20),
	[country] varchar(20)
);
 
BULK INSERT dbo.personlist
FROM 'c:\source\personlist.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',  --CSV field delimiter
	ROWTERMINATOR = '\n',   --Use to shift the control to next row
	TABLOCK,
	CODEPAGE = 'ACP'
);
 
select * from dbo.personlist;
 
The result:


If the column ‘Country’ would be removed from the file after the import has been setup, the process of importing the file would either break or be wrong (depending on the tool used to import the file) The metadata of the file has changed.

 
-- import data from file with missing column (Country)
truncate table dbo.personlist;
 
BULK INSERT dbo.personlist
FROM 'c:\source\personlistmissingcolumn.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',  --CSV field delimiter
	ROWTERMINATOR = '\n',   --Use to shift the control to next row
	TABLOCK,
	CODEPAGE = 'ACP'
);
 
select * from dbo.personlist;
 

With this example, the import seems to go well, but upon browsing the data, you’ll see that only one row is imported and the data is wrong.

The same would happen if the columns ‘Gender’ and ‘Age’ where to switch places. Maybe the import would not break, but the mapping of the columns to the destination would be wrong, as the ‘Age’ column would go to the ‘Gender’ column in the destination and vice versa. This due to the order and datatype of the columns. If the columns had the same datatype and data could fit in the columns, the import would go fine – but the data would still be wrong.

 
-- import data from file with switched columns (Age and Gender)
truncate table dbo.personlist;
 
BULK INSERT dbo.personlist
FROM 'c:\source\personlistswitchedcolumns.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',  --CSV field delimiter
	ROWTERMINATOR = '\n',   --Use to shift the control to next row
	TABLOCK,
	CODEPAGE = 'ACP'
);
 


When importing the same file, but this time with an extra column (Married) – the result would also be wrong:

 
-- import data from file with new extra column (Married)
truncate table dbo.personlist;
 
BULK INSERT dbo.personlist
FROM 'c:\source\personlistextracolumn.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',  --CSV field delimiter
	ROWTERMINATOR = '\n',   --Use to shift the control to next row
	TABLOCK,
	CODEPAGE = 'ACP'
);
 
select * from dbo.personlist; 




generateformatfile.exe -p c:\source\ -f personlist.csv -o personlistformatfile.xml -d ;

The above script generates a format file in the directory c:\source\ and names it personlistFormatFile.xml.

The content of the format file is as follows:



The console application can also be called from TSQL like this:

 
-- generate format file
declare @cmdshell varchar(8000);
set @cmdshell = 'c:\source\generateformatfile.exe -p c:\source\ -f personlist.csv -o personlistformatfile.xml -d ;'
exec xp_cmdshell @cmdshell;
 
If by any chance the xp_cmdshell feature is not enabled on your local machine – then please refer to this post from Microsoft: Enable xp_cmdshell

Using the format file

After generation of the format file, it can be used in TSQL script with OPENROWSET.

Example script for importing the ‘personlist.csv’

 
-- import file using format file
select *  
into dbo.personlist_bulk
from  openrowset(
	bulk 'c:\source\personlist.csv',  
	formatfile='c:\source\personlistformatfile.xml',
	firstrow=2
	) as t;
 
select * from dbo.personlist_bulk;
 

This loads the data from the source file to a new table called ‘personlist_bulk’.

From here the load from ‘personlist_bulk’ to ‘personlist’ is straight forward:

 
-- load data from personlist_bulk to personlist
truncate table dbo.personlist;
 
insert into dbo.personlist (name, gender, age, city, country)
select * from dbo.personlist_bulk;
 
select * from dbo.personlist;
 
drop table dbo.personlist_bulk;
 

Load data even if source changes
The above approach works if the source is the same every time it loads. But with a dynamic approach to the load from the bulk table to the destination table it can be assured that it works even if the source table is changed in both width (number of columns) and column order.

For some the script might seem cryptic – but it is only a matter of generating a list of column names from the source table that corresponds with the column names in the destination table.

 
-- import file with different structure
-- generate format file
if exists(select OBJECT_ID('personlist_bulk')) drop table dbo.personlist_bulk
 
declare @cmdshell varchar(8000);
set @cmdshell = 'c:\source\generateformatfile.exe -p c:\source\ -f personlistmissingcolumn.csv -o personlistmissingcolumnformatfile.xml -d ;'
exec xp_cmdshell @cmdshell;
 
 
-- import file using format file
select *  
into dbo.personlist_bulk
from  openrowset(
	bulk 'c:\source\personlistmissingcolumn.csv',  
	formatfile='c:\source\personlistmissingcolumnformatfile.xml',
	firstrow=2
	) as t;
 
-- dynamic load data from bulk to destination
declare @fieldlist varchar(8000);
declare @sql nvarchar(4000);
 
select @fieldlist = 
				stuff((select 
					',' + QUOTENAME(r.column_name)
						from (
							select column_name from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'personlist'
							) r
							join (
								select column_name from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'personlist_bulk'
								) b
								on b.COLUMN_NAME = r.COLUMN_NAME
						for xml path('')),1,1,'');
 
print (@fieldlist);
set @sql = 'truncate table dbo.personlist;' + CHAR(10);
set @sql = @sql + 'insert into dbo.personlist (' + @fieldlist + ')' + CHAR(10);
set @sql = @sql + 'select ' + @fieldlist + ' from dbo.personlist_bulk;';
print (@sql)
exec sp_executesql @sql
 
The result is a TSQL statement what looks like this:

 
truncate table dbo.personlist;
insert into dbo.personlist ([age],[city],[gender],[name])
select [age],[city],[gender],[name] from dbo.personlist_bulk;
 




 -- OPENROWSET SAMPLES

SELECT *
INTO 
FROM   OPENROWSET('Microsoft.ACE.OLEDB.12.0',
       'Excel 12.0 Xml;HDR=YES;Database=C:\Emp.xlsx',
       'SELECT * FROM [Employees$]')
	   
USE [SqlAndMe]

GO

 

SELECT --* INTO dbo.ImportedEmployeeData
*
FROM   OPENROWSET('Microsoft.ACE.OLEDB.12.0',
       'Excel 12.0 Xml;HDR=YES;Database=C:\Users\efras\OneDrive - AccTech Systems (Pty) Ltd\SQL Server\samples\FileSamples\data.xlsx',
       'SELECT * FROM [tab_1$]')

GO


EXEC sp_configure 'Show Advanced Options', 1

RECONFIGURE

GO

 

EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE
GO

Result Set:

	--Configuration option 'show advanced options' changed from 1 to 1. Run the RECONFIGURE statement to install
	--Configuration option 'Ad Hoc Distributed Queries' changed from 1 to 1. Run the RECONFIGURE statement to install.

 
/*
Error Message 3:

Msg 7302, Level 16, State 1, Line 1
Cannot create an instance of OLE DB provider "Microsoft.ACE.OLEDB.12.0" for linked server "(null)".
	Cause 3: You may receive this error message if registry settings are not set properly
	Solution 3: To resolve this error, run below commands to fix registry issues:
*/

EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1

GO

 

EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

GO

 



