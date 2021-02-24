CREATE OR ALTER FUNCTION [string].[TransformProperCase](
@text varchar(255))
returns table with schemabinding
as
return (
 with seed1 (a)
 as 
 (
  select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 
 ),
 numbers (n) as 
 (
  select top (datalength(@text)) row_number() over (order by (select  null))
  from seed1 s1, seed1 s2, seed1 s3
 )
 select a.b.value('(./text())[1]', 'varchar(255)') as [CleanedText]
 from (
  select
   case
    when n = 1 then upper(substring(@text, n, 1))
    when substring(@text, n - 1, 2) like '[^a-z][a-z]' collate Latin1_General_CI_AI then upper(substring(@text, n, 1))
    else lower(substring(@text, n, 1))
   end
  from numbers
  for xml path (''), type
  ) a (b)
)
GO
--EDIT: modified to cope with Acc�nted characters...Damn you Luis! I wanted to sleepBigGrin 

select * from dbo.ProperCase('o''brian lives and loves')
select * FROM master.dbo.ProperCase( 'ECHAZABAL MEDINA')