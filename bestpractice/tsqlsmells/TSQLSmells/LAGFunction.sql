Select LAG(OrderMonth)  OVER (Partition by SalesPersonId 
	                          Order by OrderMonth) as LagMonth
  from #Orders
order by SalesPersonID,OrderMonth;