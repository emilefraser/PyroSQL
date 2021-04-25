with orderedList AS (
SELECT
	full_name,
	age,
	ROW_NUMBER() OVER (ORDER BY age) AS row_n
FROM friends
),
iqr AS (
SELECT
	age,
    full_name,
	(
		SELECT age AS quartile_break
		FROM orderedList
		WHERE row_n = FLOOR((SELECT COUNT(*)
			FROM friends)*0.75)
			) AS q_three,
	(
		SELECT age AS quartile_break
		FROM orderedList
		WHERE row_n = FLOOR((SELECT COUNT(*)
			FROM friends)*0.25)
			) AS q_one,
	1.5 * ((
		SELECT age AS quartile_break
		FROM orderedList
		WHERE row_n = FLOOR((SELECT COUNT(*)
			FROM friends)*0.75)
			) - (
			SELECT age AS quartile_break
			FROM orderedList
			WHERE row_n = FLOOR((SELECT COUNT(*)
				FROM friends)*0.25)
			)) AS outlier_range
	FROM orderedList
)

SELECT full_name, age
FROM iqr
WHERE age >= ((SELECT MAX(q_three)
	FROM iqr) +
	(SELECT MAX(outlier_range)
		FROM iqr)) OR
		age <= ((SELECT MAX(q_one)
	FROM iqr) -
	(SELECT MAX(outlier_range)
		FROM iqr))