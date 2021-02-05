--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Digits, several Formats
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Digits]
(@from int=0
,@to int=9 )
RETURNS TABLE 
AS
RETURN 
(
WITH Digits(Digit) as
(
select 0 as Digit
UNION ALL
select Digit+1 from Digits where Digit <9
)
select 
Digit
,cast(ltrim(str(Digit)) as nchar(1)) as DigitChar
,cast(Quotename(ltrim(str(Digit))) as nchar(3)) as DigitCharQ
,cast('@'+ltrim(str(Digit)) as nchar(2)) as Parameter
,cast(Quotename('@'+ltrim(str(Digit))) as nchar(4)) as ParameterQ 
from Digits
where Digit between @from and @to
)
