SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW CTE.TreeView AS
with cteTree

as

(

   Select Id,PrtId,

          Name as Path1,

          cast(Null as varchar(255)) as Path2,

          cast(Null as varchar(255)) as Path3,

          cast(Null as varchar(255)) as Path4,

          cast(Null as varchar(255)) as Path5,

          0  as Level

     from CTE.PrtChild

    where PrtId is null

    union all

   Select Child.Id,

          Child.PrtID,

          Path1,

          case when Level+1 = 1 then Name else Path2 end,

          case when Level+1 = 2 then Name else Path3 end,

          case when Level+1 = 3 then Name else Path4 end,

          case when Level+1 = 4 then Name else Path5 end,

          Level+1

     from CteTree

     join CTE.PrtChild child

      on  child.PrtId = CteTree.Id

)

select * from cteTree
GO
