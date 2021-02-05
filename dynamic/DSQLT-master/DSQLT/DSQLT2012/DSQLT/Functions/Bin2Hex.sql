CREATE FUNCTION DSQLT.Bin2Hex
(
@binvalue varbinary(256)
)
RETURNS varchar(256)
AS
BEGIN
DECLARE @charvalue varchar(256)
DECLARE @i int
DECLARE @length int
DECLARE @hexstring char(16)
SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'
WHILE (@i <= @length)
	BEGIN
	DECLARE @tempint int
	DECLARE @firstint int
	DECLARE @secondint int
	SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
	SELECT @firstint = FLOOR(@tempint/16)
	SELECT @secondint = @tempint - (@firstint*16)
	SELECT @charvalue = @charvalue +
	SUBSTRING(@hexstring, @firstint+1, 1) +
	SUBSTRING(@hexstring, @secondint+1, 1)
	SELECT @i = @i + 1
	END
RETURN @charvalue
END
