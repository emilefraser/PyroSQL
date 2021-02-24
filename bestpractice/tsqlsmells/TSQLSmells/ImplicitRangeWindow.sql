/* Default is Range UNBOUNDED PRECEDING ( Defining the frame )*/
select sum(TotalDue) over(partition by SalesPersonId 
	                      order by OrderMonth 
	                 ) as RollingBalance,
       row_number() over(partition by SalesPersonId 
	                      order by OrderMonth ) as Rown
  from #Orders
order by SalesPersonID,OrderMonth;