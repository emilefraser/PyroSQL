CREATE VIEW OrderedView
as
SELECT top(10000) name
 FROM sys.objects 
 ORDER BY name
