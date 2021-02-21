SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[GetObjectDefinition]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[GetObjectDefinition] AS' 
END
GO
ALTER     PROCEDURE [meta].[GetObjectDefinition]
AS 
BEGIN

select *
from sys.sql_modules as m
inner join sys.objects AS o
oN o.object_id = m.object_id
where type = 'V'

END
 
GO
