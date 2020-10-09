SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE GetObjectDefinition
AS 
BEGIN

select *
from sys.sql_modules as m
inner join sys.objects AS o
oN o.object_id = m.object_id
where type = 'V'

END
 
GO
