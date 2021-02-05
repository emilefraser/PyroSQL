CREATE PROCEDURE [Sample].[@CopyTableTo]

AS
RETURN
BEGIN
truncate table [@1].[@2] 
insert into [@1].[@2]
select * from [@3].[@1].[@2]
END
