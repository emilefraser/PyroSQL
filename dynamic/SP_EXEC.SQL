DECLARE @LastName nvarchar(32) = 'Smith', @MaxFirstName NVARCHAR(50)
DECLARE @SQL NVARCHAR(MAX) = N'SELECT @pMaxFirstNameOUT = max(QUOTENAME(FirstName))
  FROM AdventureWorks2008.Person.Person'+CHAR(13)+
  'WHERE LastName = @pLastName'
PRINT @SQL+CHAR(13)
EXEC sp_executeSQL      @SQL,   -- getting variable input / setting variable output
                        N'@pLastName nvarchar(32),               
                          @pMaxFirstNameOUT nvarchar(50) OUTPUT', -- parms definition
                        @pLastName = @LastName,                   -- input parameter
                        @pMaxFirstNameOUT=@MaxFirstName OUTPUT    -- output parameter
 
SELECT [Max First Name] = @MaxFirstName, Legend='of last names ',
       LastName=@LastName
/* Max First Name Legend      LastName
[Zachary]   of last names     Smith   */