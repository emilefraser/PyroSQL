
IF OBJECT_ID (N'dbo.FlattenedJSON') IS NOT NULL
   DROP FUNCTION dbo.FlattenedJSON
GO
CREATE FUNCTION dbo.FlattenedJSON (@XMLResult XML)
RETURNS nvarchar(max)
WITH EXECUTE AS CALLER
AS
Begin
Declare  @JSONVersion NVarchar(max), @Rowcount int
Select @JSONVersion = '', @rowcount=count(*) from @XMLResult.nodes('/root/*') x(a)
Select @JSONVersion=@JSONVersion+
Stuff(
  (Select TheLine from 
    (Select ',
    {'+
      Stuff((Select ',"'+coalesce(b.c.value('local-name(.)', 'NVARCHAR(255)'),'')+'":"'+
       Replace( --escape tab properly within a value
         Replace( --escape return properly
           Replace( --linefeed must be escaped
             Replace( --backslash too
               Replace(coalesce(b.c.value('text()[1]','NVARCHAR(MAX)'),''),--forwardslash
               '\', '\\'),   
              '/', '\/'),   
          CHAR(10),'\n'),   
         CHAR(13),'\r'),   
       CHAR(09),'\t')   
     +'"'   
     from x.a.nodes('*') b(c) 
     for xml path(''),TYPE).value('(./text())[1]','NVARCHAR(MAX)'),1,1,'')+'}'
   from @XMLResult.nodes('/root/*') x(a)
   ) JSON(theLine)
  for xml path(''),TYPE).value('.','NVARCHAR(MAX)' )
,1,1,'')
if @Rowcount>1 Return '['+@JSONVersion+'
]'
return @JSONVersion
end








Select dbo.FlattenedJSON(
  (SELECT top 20 o.SalesOrderID, o.OrderDate, od.ProductID,
       p.Name, od.OrderQty, od.UnitPrice, od.LineTotal
   FROM AdventureWorks.Sales.SalesOrderHeader AS o
     JOIN AdventureWorks.Sales.SalesOrderDetail AS od
       ON o.SalesOrderID = od.SalesOrderID
     JOIN AdventureWorks.Production.Product AS p
       ON od.ProductID = p.ProductID
   WHERE p.Name like 'Road%'  
   FOR XML path, root)
  )
















