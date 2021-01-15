SELECT
  OrderDate = DATEADD(DAY, n, 0),
  OrderCount = COUNT(s.SalesOrderID)
FROM dbo.Numbers AS n
LEFT OUTER JOIN Sales.SalesOrderHeader AS s 
ON s.OrderDate >= CONVERT(DATETIME, @s)
  AND s.OrderDate < DATEADD(DAY, 1, CONVERT(DATETIME, @e))
  AND DATEDIFF(DAY, 0, OrderDate) = n
WHERE
  n.n >= DATEDIFF(DAY, 0, @s)
  AND n.n <= DATEDIFF(DAY, 0, @e)
GROUP BY n
ORDER BY n;