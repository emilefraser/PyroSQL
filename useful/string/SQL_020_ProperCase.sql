--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
----#################################################################################################
---- 2016-07-28 12:05:47.361 PARAGONDENTAL\lizaguirre
---- 
----#################################################################################################

----http://www.sqlservercentral.com/Forums/Topic1531616-392-2.aspx
----Here's one similar to Luis, but handles detecting the start of a word differently and works on nvarchar(4000) input.
----On the small test strings it performs about 50% slower than Luis original one, but that is just because of the NVARCHAR(4000) compatibility.
--create function [dbo].[ProperCaseN](@text nvarchar(4000))
--returns table
-- with schemabinding
--as
--return (
-- with seed1 (a)
-- as 
-- (
--  select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all 
--  select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1 union all select 1
-- ),
-- numbers (n) as 
-- (
--  select top (datalength(@text)) row_number() over (order by (select  null))
--  from seed1 s1, seed1 s2, seed1 s3
-- )
-- select a.b.value('(./text())[1]', 'nvarchar(4000)') as [text]
-- from (
--  select
--   case
--    when n = 1 then upper(substring(@text, n, 1))
--    when substring(@text, n - 1, 2) like N'[a-z][a-z]' collate Latin1_General_CI_AI then upper(substring(@text, n, 1))
--    else lower(substring(@text, n, 1))
--   end
--  from numbers
--  for xml path (''), type
--  ) a (b)
--)
use master
GO
--GO
IF OBJECT_ID('[dbo].[ProperCase]') IS NOT NULL 
DROP  FUNCTION  [dbo].[ProperCase] 
GO
--#################################################################################################
-- 2016-07-28 12:13:56.075 PARAGONDENTAL\lizaguirre
-- ITVF Propercase function that handles edge cases like O'Brian, and is as quick as it can be
--#################################################################################################
--http://www.sqlservercentral.com/Forums/Topic1531616-392-2.aspx
--Below is a varchar(255) version that is comparable to Luis, but with the extra word start checks.
--usage: select * from dbo.ProperCase('o''brian lives and loves')
create function [dbo].[ProperCase](@text varchar(255))
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
--EDIT: modified to cope with Accénted characters...Damn you Luis! I wanted to sleepBigGrin 

select * from dbo.ProperCase('o''brian lives and loves')
select * FROM master.dbo.ProperCase( 'ECHAZABAL MEDINA')