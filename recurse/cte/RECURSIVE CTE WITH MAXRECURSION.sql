WITH cte AS (
	SELECT 
		n = 1
	UNION ALL 
    SELECT
    	n + 1
    FROM 
    	cte
    WHERE
		n < 50
) 
SELECT 
	n
FROM 
	cte
OPTION (MAXRECURSIOON 200);	-- TO a limit of 32760
    