/* Values don't match */

DECLARE @tablea TABLE(
	ID INT IDENTITY(1,1),
	ColOne VARCHAR(1)
)

DECLARE @tableb TABLE(
	ID INT IDENTITY(1,1),
	ColOne VARCHAR(1)
)

INSERT INTO @tablea (ColOne)
VALUES ('A')
	, ('B')
	, ('C')
	, ('D')

INSERT INTO @tableb (ColOne)
VALUES ('A')
	, ('B')
	, ('E')
	, ('D')

SELECT b.*
FROM @tablea a
	LEFT JOIN @tableb b ON a.ID = b.ID
WHERE a.ColOne <> b.ColOne

/* Row doesn't exist */

DECLARE @tablea TABLE(
	ID INT IDENTITY(1,1),
	ColOne VARCHAR(1)
)

DECLARE @tableb TABLE(
	ID INT IDENTITY(1,1),
	ColOne VARCHAR(1)
)

INSERT INTO @tablea (ColOne)
VALUES ('A')
	, ('B')
	, ('C')
	, ('D')

INSERT INTO @tableb (ColOne)
VALUES ('A')
	, ('B')
	, ('E')

SELECT a.*
FROM @tablea a
	LEFT JOIN @tableb b ON a.ID = b.ID
WHERE b.ID IS NULL
	AND b.ColOne IS NULL
