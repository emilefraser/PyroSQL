SELECT 
    d.value('./@id', 'varchar(50)') AS 'Id'
    ,d.value('./@level', 'int') AS 'Level'
    ,(SELECT 
        f.value('./@id', 'varchar(50)') AS 'Id'
        ,f.value('./@level', 'int') AS 'Level'
        FROM c.d.nodes('./Product') AS e(f)            
        FOR JSON PATH) 'Product'
FROM @xml.nodes('/Request/SelectedProducts/Product') AS c(d)
FOR JSON PATH