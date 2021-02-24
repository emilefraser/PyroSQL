CREATE PROCEDURE dbo.TestWithNoLockNoWith
as
SELECT NAME FROM sys.objects (NOLOCK)