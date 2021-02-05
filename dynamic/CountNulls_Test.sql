--
-- Script to test the CountNulls stored procedure
--
-- 
create table t1 (id int primary key, n25 int, n50 int, n75 int, n100 int)
go
-- populate the non-key columns with data/null in the same
-- proportion to their number; ie n25 is 1/4 = 25% null.
insert into t1 (id, n25, n50, n75, n100)
select 1, NULL, NULL, NULL, NULL union
select 2,    1, NULL, NULL, NULL union
select 3,    1,    1, NULL, NULL union
select 4,    1,    1,    1, NULL
go
declare @script varchar(max)
set @script = dbo.ScriptCountNulls('t1', 'id')
exec (@script)
go
drop table t1
