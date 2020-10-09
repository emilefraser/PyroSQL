SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_set_master_switch
		@state BIT 
AS
BEGIN
	IF @state IS NULL
	BEGIN
		RAISERROR (45203, 17, 1);
		RETURN
	END

	BEGIN TRAN 
		IF NOT EXISTS (SELECT TOP 1 state FROM autoadmin_master_switch)
		BEGIN
			INSERT INTO autoadmin_master_switch VALUES (@state)
		END
		ELSE
		BEGIN
			UPDATE autoadmin_master_switch SET [state] = @state
		END
	COMMIT
END

GO
