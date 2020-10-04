REATE FUNCTION [dbo].[fn_EasterSundayByYear] 
(@Year char(4)) 
RETURNS smalldatetime 
AS 
BEGIN 
   --http://aa.usno.navy.mil/faq/docs/easter.php 
   declare 
      @c int 
    , @n int 
    , @k int 
    , @i int 
    , @j int 
    , @l int 
    , @m int 
    , @d int 
    , @Easter datetime 

   set @c = (@Year / 100) 
   set @n = @Year - 19 * (@Year / 19) 
   set @k = (@c - 17) / 25 
   set @i = @c - @c / 4 - ( @c - @k) / 3 + 19 * @n + 15 
   set @i = @i - 30 * ( @i / 30 ) 
   set @i = @i - (@i / 28) * (1 - (@i / 28) * (29 / (@i + 1)) * ((21 - @n) / 11)) 
   set @j = @Year + @Year / 4 + @i + 2 - @c + @c / 4 
   set @j = @j - 7 * (@j / 7) 
   set @l = @i - @j 
   set @m = 3 + (@l + 40) / 44 
   set @d = @l + 28 - 31 * ( @m / 4 ) 

   set @Easter = (select right('0' + convert(varchar(2),@m),2) + '/' + right('0' + convert(varchar(2),@d),2) + '/' + convert(char(4),@Year)) 

   return @Easter 


   Solution
Two holiday calculations were most interesting: Good Friday and Mardi Gras. Since both of these holidays are based on the number of days from Easter, I had to find the calculation for Easter. The calculation of Easter Sunday is based on the vernal equinox each year, and thankfully the Astronomical Applications Department of the U.S Naval Observatory has an equation that calculates it:

c = y / 100 
n = y - 19 * (y / 19) 
k = ( c - 17 ) / 25 
i = c - c / 4 - (c - k) / 3 + 19 * n + 15 
i = i - 30 * (i /30) 
i = i - (i / 28) * (1 - (i / 28) * (29 / (i + 1)) * ((21 - n) / 11)) 
j = y + y / 4 + i + 2 - c + c / 4 
j = j - 7 * (j / 7) 
l = i - j 
m = 3 + (l + 40) / 44 
d = l + 28 - 31 * (m /4) 