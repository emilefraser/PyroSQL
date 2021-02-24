Create procedure dbo.Derived
as
Select 1
 from  dbo.mytable
 left join (Select top(100) percent ID
             from  dbo.otherTable
			order by SomeThing)
			Derived
 on Derived.ID = myTable.ID



 Select 1
 from  dbo.mytable
 left join (Select top(9999) ID
             from  dbo.otherTable
			order by SomeThing)
			Derived
 on Derived.ID = myTable.ID