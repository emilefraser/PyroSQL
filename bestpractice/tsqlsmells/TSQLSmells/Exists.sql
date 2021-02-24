Create procedure ifExists
as
if(Select count(*) from dbo.myTable)>1 begin 
   print 'Rows exist'
end
