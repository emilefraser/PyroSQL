create table a(id int, fullname varchar(20))

insert into dbo.a
values (1, 'Emile Fraser')

insert into dbo.a
values (2, 'Roan Fraser')

insert into dbo.a
values (3, 'Claudine Barwiswe')

SELECT *
INTO b 
FROM a


insert into b
values (4, 'Heinre Vermaak')

drop table if exists a
--USER_TABLE
EXEC sp_rename @objname = 'b', @newname = 'a', @objtype = 'OBJECT'

SELECT * FROM a

drop table a