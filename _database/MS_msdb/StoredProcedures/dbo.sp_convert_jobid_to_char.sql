SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_convert_jobid_to_char
  @job_id         UNIQUEIDENTIFIER,
  @job_id_as_char NVARCHAR(34) OUTPUT -- 34 because of the leading '0x'
AS
BEGIN
  DECLARE @job_id_as_binary BINARY(16)
  DECLARE @temp             NCHAR(8)
  DECLARE @counter          INT
  DECLARE @byte_value       INT
  DECLARE @high_word        INT
  DECLARE @low_word         INT
  DECLARE @high_high_nybble INT
  DECLARE @high_low_nybble  INT
  DECLARE @low_high_nybble  INT
  DECLARE @low_low_nybble   INT

  SET NOCOUNT ON

  SELECT @job_id_as_binary = CONVERT(BINARY(16), @job_id)
  SELECT @temp = CONVERT(NCHAR(8), @job_id_as_binary)

  SELECT @job_id_as_char = N''
  SELECT @counter = 1

  WHILE (@counter <= (DATALENGTH(@temp) / 2))
  BEGIN
    SELECT @byte_value       = CONVERT(INT, CONVERT(BINARY(2), SUBSTRING(@temp, @counter, 1)))
    SELECT @high_word        = (@byte_value & 0xff00) / 0x100
    SELECT @low_word         = (@byte_value & 0x00ff)
    SELECT @high_high_nybble = (@high_word & 0xff) / 16
    SELECT @high_low_nybble  = (@high_word & 0xff) % 16
    SELECT @low_high_nybble  = (@low_word & 0xff) / 16
    SELECT @low_low_nybble   = (@low_word & 0xff) % 16

    IF (@high_high_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @high_high_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@high_high_nybble - 10))

    IF (@high_low_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @high_low_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@high_low_nybble - 10))

    IF (@low_high_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @low_high_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@low_high_nybble - 10))

    IF (@low_low_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @low_low_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@low_low_nybble - 10))

    SELECT @counter = @counter + 1
  END

  SELECT @job_id_as_char = N'0x' + LOWER(@job_id_as_char)
END

GO
