Create Procedure dbo.CursorTest
as

DECLARE vendor_cursor CURSOR FOR 
SELECT VendorID, Name
FROM Purchasing.Vendor
WHERE PreferredVendorStatus = 1
ORDER BY VendorID;

