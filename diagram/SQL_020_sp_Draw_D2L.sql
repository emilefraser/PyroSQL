use master;
GO
IF OBJECT_ID('[dbo].[sp_draw_d2l]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_draw_d2l] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_draw_d2l]
AS
BEGIN
--http://michaeljswart.com/2017/05/drawing-again-with-sql-server/

if object_id('#polygons') is not null
drop table #polygons;


create table #polygons
(
	polygonShape varchar(max),
	color int check (color between 1 and 100),
	intensity int check (intensity between 1 and 5)
);
declare @d nvarchar(max) = N'COMPOUNDCURVE((30.565 -75.054, 16.885 -75.054, 16.885 -17.379, 30.565 -17.379),CIRCULARSTRING(30.565 -17.379, 41.894 -22.072, 46.587 -33.401),(46.587 -33.401, 46.587 -59.032),CIRCULARSTRING(46.587 -59.032, 41.894 -70.361, 30.565 -75.054)),COMPOUNDCURVE(CIRCULARSTRING( 31.800  -1.113, 54.195 -10.390, 63.472 -32.785),(63.472 -32.785, 63.472 -59.281),CIRCULARSTRING( 63.472 -59.281, 54.195 -81.676, 31.800 -90.953),(31.800 -90.953,  8.382 -90.953),CIRCULARSTRING(  8.382 -90.953,  2.456 -88.499,  0.001 -82.572),(0.001 -82.572,  0.001  -9.489),CIRCULARSTRING(  0.001 -9.489,   2.456  -3.568,  8.382  -1.113),(8.382  -1.113, 31.800  -1.113))';
declare @2 nvarchar(max) = N'COMPOUNDCURVE(CIRCULARSTRING( 84.902 -20.184,  71.482 -14.277,  74.958  -7.677, 84.607  -1.956,  95.450  -0.022), ( 95.450  -0.022, 101.026  -0.022),CIRCULARSTRING(101.026  -0.022, 120.183  -8.368, 126.734 -31.022, 118.525 -47.436, 113.812 -51.450), (113.812 -51.450, 101.370 -60.711),CIRCULARSTRING(101.370 -60.711,  93.068 -68.181,  89.234 -74.644), ( 89.234 -74.644, 119.493 -74.644),CIRCULARSTRING(119.493 -74.644, 127.335 -82.943, 119.493 -91.120), (119.493 -91.120,  78.992 -91.120),CIRCULARSTRING( 78.992 -91.120,  71.709 -86.914,  70.649 -82.943, 79.740 -58.370,  88.364 -51.031), ( 88.364 -51.031, 103.315 -40.277),CIRCULARSTRING(103.315 -40.277, 108.092 -35.102, 110.335 -26.810, 105.167 -16.938,  92.856 -16.115), ( 92.856 -16.115,  84.902 -20.184))';
declare @l nvarchar(max) = N'COMPOUNDCURVE(CIRCULARSTRING(137.175  -8.504, 145.556  -0.001, 154.059  -8.504), (154.059  -8.504, 154.059 -74.809, 184.746 -74.809),CIRCULARSTRING(184.746 -74.809, 192.878 -82.819, 184.746 -90.952), (184.746 -90.952, 145.185 -90.952),CIRCULARSTRING(145.185 -90.952, 139.521 -88.606, 137.175 -82.942), (137.175 -82.942, 137.175  -8.504))';

insert #polygons (polygonShape, color, intensity)
select letter, color, 1
from (values (@d), (@2), (@l)) as l(letter)
cross apply (values (2), (13), (29), (45)) as c(color);

DECLARE @sql nvarchar(max) = N'';

with nums as 
(
	select TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT 1)) n
	from sys.messages
),
polygon_strings as
(
	select replicate('CURVEPOLYGON(' + polygonShape + '),', intensity) as shape, color 
	from #polygons
	union 
	select 'CURVEPOLYGON((0 0, 0 0.1, 0.1 0, 0 0)),', n
	from nums
),
joined_strings as
(
   select n, ( 
       select shape as [data()] 
	   from polygon_strings
	   where color = n
	   for xml path('') ) as shape
   from nums
)
select @sql = @sql + 'SELECT geometry::STGeomFromText(''GEOMETRYCOLLECTION('
       + left(shape, len(shape)-1)
	   + ')'', 0) ' 
	   + CASE WHEN n = 100 THEN '' ELSE 'UNION ALL ' END
from joined_strings
order by n;

exec sp_executesql @sql;
END -- PROC