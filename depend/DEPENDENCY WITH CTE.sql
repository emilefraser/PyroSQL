with        cte (lvl,object_id,name)
            as 
            (
                select      1
                           ,object_id
                           ,name

                from        sys.tables

                where       type_desc       = 'USER_TABLE'
                        and is_ms_shipped   = 0

                union all

                select      cte.lvl + 1
                           ,t.object_id
                           ,t.name
                from                    cte

                            join        sys.tables  as t

                            on          exists
                                        (
                                            select      null

                                            from        sys.foreign_keys    as fk

                                            where       fk.parent_object_id     = t.object_id 
                                                    and fk.referenced_object_id = cte.object_id
                                        )

                                    and t.object_id <> cte.object_id
                                    and cte.lvl < 30

                where       t.type_desc     = 'USER_TABLE'      
                        and t.is_ms_shipped = 0
            )


select      name
           ,max (lvl)   as dependency_level

from        cte

group by    name

order by    dependency_level
           ,name
;