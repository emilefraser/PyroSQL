with orderedList AS (
SELECT
	full_name,
	age,
	ROW_NUMBER() OVER (ORDER BY age) AS row_n
FROM friends
),

quartile_breaks AS (
SELECT
	age,
    full_name,
	(
	SELECT age AS quartile_break
	FROM orderedList
	WHERE row_n = FLOOR((SELECT COUNT(*) FROM friends)*0.75)
	) AS q_three_lower,
	(
	SELECT age AS quartile_break
	FROM orderedList
	WHERE row_n = FLOOR((SELECT COUNT(*) FROM friends)*0.75) + 1
	) AS q_three_upper,
	(
	SELECT age AS quartile_break
	FROM orderedList
	WHERE row_n = FLOOR((SELECT COUNT(*) FROM friends)*0.25)
	) AS q_one_lower,
	(
	SELECT age AS quartile_break
	FROM orderedList
	WHERE row_n = FLOOR((SELECT COUNT(*) FROM friends)*0.25) + 1
	) AS q_one_upper
	FROM orderedList
	),

iqr AS (
SELECT
	age,
    full_name,
	(
	(SELECT MAX(q_three_lower)
    	FROM quartile_breaks) +
	(SELECT MAX(q_three_upper)
    	FROM quartile_breaks)
	)/2 AS q_three,
	(
	(SELECT MAX(q_one_lower)
    	FROM quartile_breaks) +
	(SELECT MAX(q_one_upper)
    	FROM quartile_breaks)
	)/2 AS q_one,
	1.5 * ((
	(SELECT MAX(q_three_lower)
    	FROM quartile_breaks) +
	(SELECT MAX(q_three_upper)
    	FROM quartile_breaks)
	)/2 - (
	(SELECT MAX(q_one_lower)
    	FROM quartile_breaks) +
	(SELECT MAX(q_one_upper)
    	FROM quartile_breaks)
	)/2) AS outlier_range
FROM quartile_breaks
)

SELECT
	full_name,
    age
FROM iqr
WHERE age >=
	((SELECT MAX(q_three)
		FROM iqr) +
	(SELECT MAX(outlier_range)
		FROM iqr))
 OR age <=
 	((SELECT MAX(q_one)
		FROM iqr) -
	(SELECT MAX(outlier_range)
		FROM iqr))