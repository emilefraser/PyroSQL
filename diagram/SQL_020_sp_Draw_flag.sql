use master;
GO
IF OBJECT_ID('[dbo].[sp_draw_flag]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_draw_flag] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_draw_flag]
AS
BEGIN
--http://michaeljswart.com/2017/05/drawing-again-with-sql-server/


declare @xoffset numeric(7,3) = 90;
declare @yoffset numeric(7,3) = -164;
declare @scale_star numeric(7,3) = 250;
declare @scale_x numeric(7,3) = 250;
declare @scale_y numeric(7,3) = -210;
declare @stars_xml xml;

with star as 
(
  SELECT *                   
  FROM ( VALUES (0, 0, 1),(0.382, 0, 2),(0.5, 0.363, 3),(0.618, 0, 4),
	  (1, 0, 5),(0.691, -0.225, 6),(0.809, -0.588, 7),(0.5, -0.363, 8),
	  (0.191, -0.588, 9),(0.309, -0.224, 10),(0, 0, 11) ) as star(x,y,n)
),
grid as
(
  SELECT 2 * xIndex.id + case when yIndex.id % 2 = 1 then 1 else 0 end as x,
		 yIndex.id as y,
		 row_number() over (order by (select 1)) as star_number
    FROM ( VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8) ) yIndex(id)
   CROSS JOIN ( VALUES (0), (1), (2), (3), (4), (5) ) xIndex(id)
   WHERE (xIndex.id < 5 or yIndex.id % 2 = 0)
)
select @stars_xml = (
SELECT ',(' +
  STUFF(CAST(( 
    SELECT ',' + cast(cast(@xoffset + (star.x * @scale_star) + grid.x * @scale_x as numeric(7,3)) as sysname) + 
           ' ' + cast(cast(@yoffset + (star.y * @scale_star) + grid.y * @scale_y as numeric(7,3)) as sysname)
      FROM star
     ORDER BY star.n
     FOR XML PATH(''),TYPE 
  ) AS VARCHAR(MAX)), 1, 1, '') + ')'
FROM grid
FOR XML PATH(''),TYPE);

create table #polygons
(
	polygonShape varchar(max),
	color int check (color between 1 and 100),
	intensity int check (intensity between 1 and 5)
);

insert #polygons (polygonShape, color, intensity)
values 
('(2964 -0   , 7410 -0   , 7410 -300 , 2964 -300 , 2964 -0   )', 95, 5),
('(2964 -600 , 7410 -600 , 7410 -900 , 2964 -900 , 2964 -600 )', 95, 5),
('(2964 -1200, 7410 -1200, 7410 -1500, 2964 -1500, 2964 -1200)', 95, 5),
('(2964 -1800, 7410 -1800, 7410 -2100, 2964 -2100, 2964 -1800)', 95, 5),
('(0    -2400, 7410 -2400, 7410 -2700, 0    -2700, 0    -2400)', 95, 5),
('(0    -3000, 7410 -3000, 7410 -3300, 0    -3300, 0    -3000)', 95, 5),
('(0    -3600, 7410 -3600, 7410 -3900, 0    -3900, 0    -3600)', 95, 5),
('(0    -0   , 2964 -0   , 2964 -2100, 0    -2100, 0    -0   )'
 + cast(@stars_xml as varchar(max)), 76, 5);

-- better blue
insert #polygons (polygonShape, color, intensity)
select polygonshape, 14, 3 from #polygons where color = 76;
insert #polygons (polygonShape, color, intensity)
select polygonshape, 15, 3 from #polygons where color = 76;
delete #polygons where color = 76;

-- better red
insert #polygons (polygonShape, color, intensity)
select polygonshape, 2, 1 from #polygons where color = 95;
insert #polygons (polygonShape, color, intensity)
select polygonshape, 45, 3 from #polygons where color = 95;
update #polygons set intensity = 2 where color = 95;

DECLARE @sql nvarchar(max) = N'';

with nums as 
(
	select TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT 1)) n
	from sys.messages
),
polygon_strings as
(
	select replicate('POLYGON(' + polygonShape + '),', intensity) as shape, color 
	from #polygons
	union 
	select 'POLYGON((0 0, 0 1, 1 0, 0 0)),', n
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
	
drop table #polygons;

END --PROC