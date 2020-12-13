CREATE FUNCTION [dbo].[FnJsonEscape](@val nvarchar(max) )

returns nvarchar(max)

as begin

if (@val is null) return 'null'
if (TRY_PARSE( @val as float) is not null) return @val
set @val=replace(@val,'\','\\')
set @val=replace(@val,'"','\"')
return '"'+@val+'"'
end
GO

CREATE FUNCTION [dbo].[FnXmlToJson](@Xml XML)

RETURNS NVARCHAR(MAX)

AS
BEGIN
DECLARE @json NVARCHAR(MAX);
SELECT @json = STUFF(
(
SELECT JSONValue
FROM
(
SELECT ','+' {'+STUFF(
(
SELECT ',"'+COALESCE(b.c.value('local-name(.)', 'NVARCHAR(max)'), '')+'":'+CASE
WHEN b.c.value('count(*)', 'int') = 0
THEN dbo.[FnJsonEscape](b.c.value('text()[1]', 'NVARCHAR(MAX)'))
ELSE dbo.FnXmlToJson(b.c.query('*'))
END
FROM x.a.nodes('*') b(c)
FOR XML PATH(''), TYPE
).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 1, '')+'}'
FROM @Xml.nodes('/*') x(a)
) JSON(JSONValue)
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '');
RETURN @json;
END;
GO

CREATE FUNCTION [dbo].[FnXmlToJsonList](@Xml XML)

RETURNS NVARCHAR(MAX)

AS
BEGIN
DECLARE @json NVARCHAR(MAX);
SELECT @json = '[' + STUFF(
(
SELECT JSONValue
FROM
(
SELECT ','+' {'+STUFF(
(
SELECT ',"'+COALESCE(b.c.value('local-name(.)', 'NVARCHAR(max)'), '')+'":'+CASE
WHEN b.c.value('count(*)', 'int') = 0
THEN dbo.[FnJsonEscape](b.c.value('text()[1]', 'NVARCHAR(MAX)'))
ELSE dbo.FnXmlToJson(b.c.query('*'))
END
FROM x.a.nodes('*') b(c)
FOR XML PATH(''), TYPE
).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 1, '')+'}'
FROM @Xml.nodes('/*') x(a)
) JSON(JSONValue)
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '')+']';
RETURN @json;
END;
GO