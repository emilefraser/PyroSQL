
CREATE FUNCTION [DSQLT].[aMillionNumbers]
(@from INT=0, @to INT=999999)
RETURNS TABLE 
AS
RETURN 
WITH Digits as
(SELECT Digit from DSQLT.Digits(0,9))
,Numbers as
(
SELECT A.Digit+B.Digit*10+C.Digit*100+D.Digit*1000+E.Digit*10000+F.Digit*100000 as Number
from Digits A
cross join Digits B
cross join Digits C
cross join Digits D
cross join Digits E
cross join Digits F
)
select Number from Numbers 
where Number between @from and @to