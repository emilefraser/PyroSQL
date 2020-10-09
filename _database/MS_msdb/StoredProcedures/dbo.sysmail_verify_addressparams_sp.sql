SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_verify_addressparams_sp
  @address          VARCHAR(MAX),
  @parameter_name   NVARCHAR(32)
AS
  IF ((@address IS NOT NULL) AND (@address != N''))
  BEGIN

    DECLARE @curr_char NVARCHAR(1)
    DECLARE @curr_char_index INT
    DECLARE @in_double_quotes BIT
    DECLARE @error_at INT

    SET @curr_char = N''        -- current character being analyzed
    SET @curr_char_index = 1    -- position of current character being analyzed
    SET @in_double_quotes = 0   -- flag (1=within double quotes; 0 otherwise)
    SET @error_at = 0           -- position (starting at 1) where the illegal comma was detected

    WHILE @curr_char_index <= len(@address)
    BEGIN
        SET @curr_char = substring(@address, @curr_char_index, 1)
        IF @curr_char = N'"'
          SET @in_double_quotes = CASE @in_double_quotes WHEN 0 THEN 1 ELSE 0 END

        IF @curr_char = N','
          SET @error_at = CASE @in_double_quotes WHEN 1 THEN 0 ELSE @curr_char_index END

        IF @error_at > 0 BREAK

        SET @curr_char_index = @curr_char_index + 1
    END

    IF @error_at > 0 
    BEGIN
      -- Comma is the wrong format to separate addresses. Users should use the semicolon ";".
      RAISERROR(14613, 16, 1, @parameter_name, @address)
      RETURN(1)
    END

  END

  RETURN(0) -- SUCCESS

GO
