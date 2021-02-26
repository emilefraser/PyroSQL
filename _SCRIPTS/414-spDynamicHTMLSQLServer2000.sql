alter procedure spDynamicHTMLCrossTab

@RowValue VARCHAR(255), --what is the row header
@ColValue VARCHAR(255), --what is the column header
@Aggregate VARCHAR(255), --the aggregation value
@FromExpression VARCHAR(8000), --the FROM, ON and WHERE clause
@colOrderValue VARCHAR (255)=null, --how the columns are ordered
@Title varchar(80)='_', --the title to put in the first col of first row
@RowSort Varchar(80)=null,--any special way the rows should be sorted
@SortBy Varchar(255)='row asc', --what you sort the rows by (column heading)
@UnitBefore Varchar(10)='',--the unit that each value has before (e.g. £ or $)
@UnitAfter Varchar(10)='',--The unit that each value has after e.g. %
@ReturnTheDDL int=0,--we return just the DLL
@Debugging int=0,--we look at the intermediate code
@output varchar(8000) ='none' output,
@style varchar(8000)='<style type="text/css">
/*<![CDATA[*/
<!--
#MyCrosstab {
	font-family: Arial, Helvetica, sans-serif; font-size:small;
}
#MyCrosstab td{font-size:small; padding: 3px 10px 2px 10px; }
#MyCrosstab td.number{ text-align: right; }
#MyCrosstab td.rowhead{ border-right: 1px dotted #828282; font-weight: bold;}
#MyCrosstab th{ font-size:small; border-bottom: 1px dotted #828282; text-align: center; }
#MyCrosstab .sum{ border-top: 2px solid #828282; }
#MyCrosstab .sumrow{ text-align: right }
#MyCrosstab .total{ border-left: 1px solid #828282; }
-->
/*]]>*/
</style>
'

/*
Declare @HTMLString varchar(8000) 
EXECUTE spDynamicHTMLCrossTab 
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
	@Unitbefore='$',
	@sortby='total desc',
	@Title ='value of orders per quarter',
	@Output=@HTMLString output
Select @HTMLString

Execute spDynamicHTMLCrossTab 
    @RowValue='firstname+'' ''+lastname', 
    @ColValue='DATENAME(year,orderDate)', 
    @Aggregate= 'sum(subtotal)', 
    @FromExpression='FROM Orders  
   INNER JOIN "Order Subtotals"  
       ON Orders.OrderID = "Order Subtotals".OrderID 
   inner join employees on employees.EmployeeID =orders.EmployeeID', 
    @ColOrderValue='datepart(year,orderDate)', 
	@Unitbefore='$',
	@sortby='total desc',
   @Title ='Revenue per salesman per year '

Execute spDynamicHTMLCrossTab
    @RowValue='firstname+'' ''+lastname',
    @ColValue='Year(OrderDate)',
    @Aggregate= 'count(*)',
    @FromExpression='FROM Employees INNER JOIN Orders 
    ON (Employees.EmployeeID=Orders.EmployeeID)',
    @ColOrderValue='Year(OrderDate)',
	@Title ='No. Sales per year',
	@SortBy ='total desc', --what you sort the rows by (column heading)
    @ReturnTheDDL =0,
    @debugging=0
*/
as
set nocount on
DECLARE @Command NVARCHAR(4000)
DECLARE @DataRows VARCHAR(8000)
Declare @HeadingLines varchar(8000)
--make sure we have sensible defaults for orders
Select @ColOrderValue=coalesce(@ColOrderValue, @ColValue),
    @rowsort=coalesce(@RowSort,@RowValue),
	@Sortby=coalesce(@SortBy,@RowValue)
--first construct tha SQL which is used to calculate the columns in a 
--string
create TABLE #StringTable 
  (
    MyID INT IDENTITY(1, 1),
    string VARCHAR(8000),
    waste numeric(19,8)
  )

SELECT 

	@Command='Select 
 @Headinglines=coalesce(@headinglines,''<div id="MyCrosstab">
<h3>'+@title+'</h3>
<table cellpadding="0" cellspacing="0">
<thead>
<tr class="header"><th> </th>'')+''<th>''
	+max(convert(varchar(100),'
   +@ColValue+')) +''</th>'',
 @DataRows=coalesce(@DataRows,
''SELECT 
[string]=''''<tr>
  <td class="rowhead''''
+ case when grouping(row)<>0 then'''' sumrow'''' else '''''''' end
+''''">''''+convert(varchar(100),case when row is null 
then ''''Sum'''' else [row] end)+''''</td>
'')
 +''<td class="''''
+ case when grouping(row)<>0 then''''sum'''' else '''''''' end
+'''' number">''''+'''''+@unitBefore+'''''+convert(varchar(100),sum( CASE col WHEN ''''''
 +max(convert(varchar(100),'
   +@ColValue+'))
 +'''''' THEN data else 0 END ))++'''''+@unitAfter+'''''+''''</td>
''  '+@FromExpression+'
GROUP BY '+@ColValue+'
order by max('+@ColorderValue+')'
--Now we execute the string to obtain the SQL that we will use for the
--crosstab query
Select @Command
EXECUTE sp_ExecuteSQL @command,N'@DataRows VARCHAR(8000) OUTPUT,
  @Headinglines VARCHAR(8000) OUTPUT', @DataRows output,@Headinglines OUTPUT
  IF @@error > 0 --display the string if there is an error
    BEGIN
      RAISERROR ( 'offending first-phase code was ...%s', 0, 1, @command )
      RETURN 1
    END
if @Debugging <>0 select @Command

insert into  #StringTable(string) Select @Style
insert into  #StringTable(string) select @Headinglines+'<th>Total</th></tr>
   </thead>
   <tbody>'
Select @DataRows=
@DataRows+'<td class="''
  + case when grouping(row)<>0 then''sum'' else '''' end+'' number total">''
  +'''+@unitBefore+'''+convert(varchar(100),sum( data ))+'''+@unitAfter
  +'''+''</td></tr>'', [total]=convert(numeric(19,8),sum( data ))
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
if @ReturnTheDDL<>0 SELECT @DataRows else
	insert into  #StringTable(string,waste)
		EXECUTE (@DataRows)
  IF @@error > 0 
    BEGIN
      RAISERROR ( 'offending second-phase code was ...%s', 0, 1, @DataRows )
      RETURN 1
    END
insert into  #StringTable(string) select '</tbody></table></div>'

if @Output='none' 
    Select string from #StringTable order by MyID
else 
    Select @Output=coalesce(@Output,'')+ string 
       from #StringTable 
       order by MyID