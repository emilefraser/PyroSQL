SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE DATEANDTIME.DateConversionTest
AS
BEGIN
	DECLARE @varDate DATE = '2020-01-02'
	DECLARE @varDateTime_0 DATETIME = '2020-01-02 00:00:00'
	DECLARE @varDateTime_0_WT DATETIME = '2020-01-02 14:24:11'
	DECLARE @varDateTime_3 DATETIME = '2020-01-02 00:00:00.000'
	DECLARE @varDateTime2_3 DATETIME2(3) = '2020-01-02 00:00:00.000'
	DECLARE @varDateTime2_7 DATETIME2(7) = '2020-01-02 00:00:00.0000000'
	DECLARE @varDateTime2_7_WT DATETIME2(7) = '2020-01-02 14:24:11.1145355'
	DECLARE @varSmallDateTime SMALLDATETIME = '2020-01-02 00:00:00'

	IF(@varDate = @varDateTime_0)
	BEGIN
		PRINT('DATE = DATETIME')
		--PRINT(@varDate + ' = ' + @varDateTime_0)
	END
	ELSE
	BEGIN
		PRINT('DATE != DATETIME')
		--PRINT(@varDate + ' != ' + @varDateTime_0)
	END

	IF(@varDate = @varDateTime_0_WT)
	BEGIN
		PRINT('DATE = DATETIME (With Time)')
		--PRINT(@varDate + ' = ' + @varDateTime_0)
	END
	ELSE
	BEGIN
		PRINT('DATE != DATETIME (With Time)')
		--PRINT(@varDate + ' != ' + @varDateTime_0)
	END


	IF(@varDate = @varDateTime2_7)
	BEGIN
		PRINT('DATE = DATETIME2(7)')
		--PRINT(@varDate + ' = ' + @varDateTime2_7)
	END
	ELSE
	BEGIN
		PRINT('DATE != DATETIME2(7)')
		--PRINT(@varDate + ' != ' + @varDateTime2_7)
	END

	
	IF(@varDate = @varDateTime2_7_WT)
	BEGIN
		PRINT('DATE = DATETIME2(7) (With Time)')
		--PRINT(@varDate + ' = ' + @varDateTime2_7)
	END
	ELSE
	BEGIN
		PRINT('DATE != DATETIME2(7) (With Time)')
		--PRINT(@varDate + ' != ' + @varDateTime2_7)
	END
END

GO
