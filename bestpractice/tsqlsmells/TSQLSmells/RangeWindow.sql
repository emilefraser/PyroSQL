/* Default is Range UNBOUNDED PRECEDING ( Defining the frame )*/
select sum(TotalDue) over(partition by SalesPersonId 
	                      order by OrderMonth 
	                 Range UNBOUNDED PRECEDING) as RollingBalance
  from #Orders
order by SalesPersonID,OrderMonth;