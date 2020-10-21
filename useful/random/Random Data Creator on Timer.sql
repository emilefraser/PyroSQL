DECLARE @x INT  = 0
DECLARE @y INT  = 0
DECLARE @z INT  = 0
DECLARE @charCapitalStart SMALLINT = 65
DECLARE @charCapitalEnd SMALLINT = 65 + 26 - 1
DECLARE @charLowerStart SMALLINT = 97
DECLARE @charLowerEnd SMALLINT = 97 + 26 - 1
DECLARE @numberStart SMALLINT = 48
DECLARE @numberEnd SMALLINT = 57

DECLARE @NameLength SMALLINT 
DECLARE @EarningLength SMALLINT 

DECLARE @Name NVARCHAR(MAX) = ''
DECLARE @Earning NVARCHAR(MAX) = ''
DECLARE @EarningNumber INT

DECLARE @IsDebug BIT = 1
DECLARE @sql_message NVARCHAR(MAX) = ''

WHILE (@x <= 1000)
BEGIN
	
	SET @NameLength = (SELECT ROUND(RAND() * 10.0,0) + 3)
	SET @EarningLength = (SELECT ROUND(RAND() * 3.0,0) + 3)

	IF @IsDebug = 1
	BEGIN
		SET @sql_message = '@NameLength = ' + CONVERT(NVARCHAR, @NameLength)
		RAISERROR(@sql_message,0,1) WITH NOWAIT
		SET @sql_message = '@EarningLength = ' + CONVERT(NVARCHAR, @EarningLength)
		RAISERROR(@sql_message,0,1) WITH NOWAIT
	END

	SET @Name = CHAR(FLOOR(RAND() * (@charCapitalEnd - @charCapitalStart + 1) + @charCapitalStart))

	IF @IsDebug = 1
	BEGIN
		SET @sql_message = '@Name = ' + CONVERT(NVARCHAR, @Name)
		RAISERROR(@sql_message, 0,1) WITH NOWAIT
	END

	SET @y = 0
	WHILE (@y <= @NameLength)
	BEGIN
		SET @Name += CHAR(FLOOR(RAND() * (@charLowerEnd - @charLowerStart + 1) + @charLowerStart))
		SET @y += 1
	END

	IF @IsDebug = 1
	BEGIN
		SET @sql_message = '@Name = ' + CONVERT(NVARCHAR, @Name)
		RAISERROR(@sql_message, 0,1) WITH NOWAIT
	END


	SET @z = 0
	SET @Earning = ''
	WHILE (@z <= @EarningLength)
	BEGIN
		SET @Earning += CHAR(FLOOR(RAND() * (@numberEnd - @numberStart + 1) + @numberStart))
		SET @z += 1
	END

	IF @IsDebug = 1
	BEGIN
		SET @sql_message = '@Earning = ' + CONVERT(NVARCHAR, @Earning)
		RAISERROR(@sql_message, 0,1) WITH NOWAIT
	END

	SET @EarningNumber = (SELECT CONVERT(INT, @Earning))

	INSERT INTO dbo.OriginalValues ([Name], [Earnings], [CreatedDT])
	VALUES (@Name, @EarningNumber, GETDATE())

	SELECT * FROM dbo.OriginalValues 

	-- Wait for 15 seconds
	WAITFOR DELAY '00:00:15'

	-- Increase the counter
	SET @x += 1

END


--TRUNCATE TABLE dbo.OriginalValues 