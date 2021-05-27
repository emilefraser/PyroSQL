SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ImportJsonFromAzBlobToLocal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ImportJsonFromAzBlobToLocal] AS' 
END
GO

ALTER PROCEDURE [inout].[ImportJsonFromAzBlobToLocal] 
AS 
BEGIN
SELECT 'TODO'
/*

Import JSON documents from Azure File Storage
You can also use OPENROWSET(BULK) as described above to read JSON files from other file locations that SQL Server can access. For example, Azure File Storage supports the SMB protocol. As a result you can map a local virtual drive to the Azure File storage share using the following procedure:

Create a file storage account (for example, mystorage), a file share (for example, sharejson), and a folder in Azure File Storage by using the Azure portal or Azure PowerShell.

Upload some JSON files to the file storage share.

Create an outbound firewall rule in Windows Firewall on your computer that allows port 445. Note that your Internet service provider may block this port. If you get a DNS error (error 53) in the following step, then you have not opened port 445, or your ISP is blocking it.

Mount the Azure File Storage share as a local drive (for example T:).

Here is the command syntax:

dos

Copy
net use [drive letter] \\[storage name].file.core.windows.net\[share name] /u:[storage account name] [storage account access key]
Here's an example that assigns local drive letter T: to the Azure File Storage share:

dos

Copy
net use t: \\mystorage.file.core.windows.net\sharejson /u:myaccount hb5qy6eXLqIdBj0LvGMHdrTiygkjhHDvWjUZg3Gu7bubKLg==
You can find the storage account key and the primary or secondary storage account access key in the Keys section of Settings in the Azure portal.

Now you can access your JSON files from the Azure File Storage share by using the mapped drive, as shown in the following example:

SQL

Copy
SELECT book.* FROM
 OPENROWSET(BULK N't:\books\books.json', SINGLE_CLOB) AS json
 CROSS APPLY OPENJSON(BulkColumn)
 WITH( id nvarchar(100), name nvarchar(100), price float,
    pages_i int, author nvarchar(100)) AS book
For more info about Azure File Storage, see File storage.


*/
END
GO
