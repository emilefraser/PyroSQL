SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[ProperCase]  
(  
@Input as varchar(8000)  
)  
RETURNS varchar(8000)  
AS  
BEGIN  
DECLARE @Reset bit,  
@Proper varchar(8000),  
@Counter int,  
@FirstChar char(1)  
SELECT @Reset = 1, @Counter = 1, @Proper = ''  
WHILE (@Counter <= LEN(@Input))  
BEGIN  
SELECT @FirstChar = SUBSTRING(@Input, @Counter, 1),  
@Proper = @Proper + CASE WHEN @Reset = 1 THEN UPPER(@FirstChar) ELSE LOWER(@FirstChar) END,  
@Reset = CASE WHEN @FirstChar LIKE '[a-zA-Z]' THEN 0 ELSE 1 END,  
@Counter = @Counter + 1  
END  
SELECT @Proper = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Proper)),' ',' '+ CHAR(7)) , CHAR(7)+' ',''), CHAR(7),'')  
WHERE CHARINDEX(' ', @Proper) > 0  
RETURN @Proper  
END  
GO
