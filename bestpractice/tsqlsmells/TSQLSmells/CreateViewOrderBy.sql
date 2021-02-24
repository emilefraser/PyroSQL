Create view dbo.Dave
as
Select top(100000) name
from sys.objects
order by name