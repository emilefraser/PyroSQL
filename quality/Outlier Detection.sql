DECLARE @Mean				DECIMAL(5,2)
DECLARE @StdDev				DECIMAL(5,2) 
DECLARE @StdDevFromMean		INT				= 3 -- 1 would give you 68.2% certainty, 2 would give you 95% and 3 99.7%

-- Calculation of @Mean and @Standard Deviation
SELECT 
   @StdDev		= STDEV({{columnname}}), 
   @Mean		= AVG({{columnname}}) 
FROM 
	{{tablename}}.{{tablename}}

-- Identify the outliers
SELECT 
   * 
FROM 
   {{tablename}}.{{tablename}} 
WHERE 
   {{columnname}} >  (@Mean - (@StdDevFromMean * @StdDev))
 OR
   {{columnname}} <  (@Mean + (@StdDevFromMean * @StdDev))