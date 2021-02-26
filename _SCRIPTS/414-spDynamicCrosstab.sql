alter procedure spDynamicCrossTab

@RowValue VARCHAR(255),         --what is the SQL for the row title 
@ColValue VARCHAR(255),         --what is the SQL for the column title
@Aggregate VARCHAR(255),        --the aggregation value to go in the cells
@FromExpression VARCHAR(8000),              --the FROM, ON and WHERE clause
@colOrderValue VARCHAR (255)=null,            --how the columns are ordered
@Title varchar(80)='_',    --the title to put in the first col of first row
@SortBy Varchar(255)='row asc', --what you sort the rows by (column heading)
@RowSort Varchar(80)=null,
@ReturnTheDDL int=0,--return the SQL code rather than execute it
@Debugging int=0    --debugging mode
/*
e.g.
Execute spDynamicCrossTab
    @RowValue='firstname+'' ''+lastname',
    @ColValue='Year(OrderDate)',
    @Aggregate= 'count(*)',
    @FromExpression='FROM Employees INNER JOIN Orders 
    ON (Employees.EmployeeID=Orders.EmployeeID)',
    @ColOrderValue='Year(OrderDate)',
	@Title ='No. Sales per year',
	@SortBy ='total desc' --what you sort the rows by (column heading)

Execute spDynamicCrossTab
    @RowValue='firstname+'' ''+lastname',
    @ColValue='DATENAME(month,orderDate)',
    @Aggregate= 'sum(subtotal)',
    @FromExpression='FROM Orders 
   INNER JOIN "Order Subtotals" 
       ON Orders.OrderID = "Order Subtotals".OrderID
   inner join employees on employees.EmployeeID =orders.EmployeeID',
    @ColOrderValue='datepart(month,orderDate)',
	@Title ='Customers orders per month '

EXECUTE spDynamicCrossTab 
    @RowValue='country',
    @ColValue='datename(quarter,orderdate)
     +case datepart(quarter,orderdate) 
         when 1 then ''st'' 
         when 2 then ''nd'' 
         when 3 then ''rd'' 
         when 4 then ''th'' end',
    @Aggregate= 'sum(subtotal)',
    @FromExpression='FROM Orders 
   INNER JOIN "Order Subtotals" 
       ON Orders.OrderID = "Order Subtotals".OrderID
  inner join customers on customers.customerID =orders.customerID',
    @ColOrderValue='datepart(quarter,orderDate)',
	@sortby='total desc',
	@Title ='value of orders per quarter'

*/
as
set nocount on
DECLARE @Command NVARCHAR(MAX)
DECLARE @SQL VARCHAR(MAX)
--make sure we have sensible defaults for orders
Select @ColOrderValue=coalesce(@ColOrderValue, @ColValue),
	@Sortby=coalesce(@SortBy,@RowValue),
    @rowsort=coalesce(@RowSort,@RowValue)
--first construct tha SQL which is used to calculate the columns in a 
--string
SELECT @Command='select @SQL=coalesce(@SQL,''SELECT 
  ['+@Title+']=case when row is null then ''''Sum'''' 
								else convert(Varchar(80),[row]) end ,
'')+
  ''[''+convert(varchar(100),'
   +@ColValue+')+''] =sum( CASE col WHEN ''''''+convert(varchar(100),'
   +@ColValue+')+'''''' THEN data else 0 END ),
'' '+@FromExpression+'
GROUP BY '+@ColValue+'
order by max('+@ColorderValue+')'
--Now we execute the string to obtain the SQL that we will use for the
--crosstab query
EXECUTE sp_ExecuteSQL @command,N'@SQL VARCHAR(MAX) OUTPUT',@SQL OUTPUT
  IF @@error > 0 --display the string if there is an error
    BEGIN
      RAISERROR ( 'offending code was ...%s', 0, 1, @command )
      RETURN 1
    END
if @debugging <>0 select @Command
--we now add the rest of the SQL into the string
SELECT @SQL=@SQL+'  [Total]= sum( data )
from 
   (select [row]='+@RowValue+', 
           [col]='+@ColValue+', 
           [data]='+@Aggregate+',
           [sort]=max('+@rowsort+')
 '+@FromExpression+' 
    GROUP BY '+@RowValue+', '+@ColValue+'
	)f
group by row with rollup
order by grouping(row),'+@Sortby
--and execute it
if @ReturnTheDDL<>0 SELECT @SQL else Execute (@SQL)
  IF @@error > 0 
    BEGIN
      RAISERROR ( 'offending code was ...%s', 0, 1, @sql )
      RETURN 1
    END



