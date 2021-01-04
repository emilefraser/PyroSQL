DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT ',' + QUOTENAME(ColumnName) 
                    from yourtable
                    group by ColumnName, id
                    order by id
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

set @query = N'SELECT ' + @cols + N' from 
             (
                select value, ColumnName
                from yourtable
            ) x
            pivot 
            (
                max(value)
                for ColumnName in (' + @cols + N')
            ) p '

exec sp_executesql @query;