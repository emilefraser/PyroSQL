-- Dynamic SQL execution with input / output parameters
-- SQL Server dynamic query - QUOTENAME - mssql dynamic sql variables
USE AdventureWorks2008;
DECLARE  @ParmDefinition NVARCHAR(1024) = N'@pFirstLetterOfLastName char(1),
      @pLastFirstNameOUT nvarchar(50) OUTPUT'
DECLARE @FirstLetter CHAR(1) = 'E', @LastFirstName NVARCHAR(50)
DECLARE @SQL NVARCHAR(MAX) = N'SELECT @pLastFirstNameOUT = max(QUOTENAME(FirstName))
      FROM Person.Person'+CHAR(13)+
      'WHERE left(LastName,1) = @pFirstLetterOfLastName'
PRINT @SQL+CHAR(13)
/*
SELECT @pLastFirstNameOUT = max(QUOTENAME(FirstName))
      FROM Person.Person
WHERE left(LastName,1) = @pFirstLetterOfLastName
*/
PRINT @ParmDefinition
/*
@pFirstLetterOfLastName char(1),
      @pLastFirstNameOUT nvarchar(50) OUTPUT
*/
-- Dynamic SQL with parameters, including OUTPUT parameter
EXECUTE sp_executeSQL
      @SQL,
      @ParmDefinition,
      @pFirstLetterOfLastName = @FirstLetter,
      @pLastFirstNameOUT=@LastFirstName OUTPUT
 
SELECT
      [Last First Name] = @LastFirstName,
      Legend='of last names starting with',
      Letter=@FirstLetter
GO
/* Results
Last First Name   Legend                        Letter
[Xavier]          of last names starting with   E
*/