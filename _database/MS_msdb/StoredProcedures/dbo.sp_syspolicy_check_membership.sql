SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syspolicy_check_membership]
@role sysname,
@raiserror bit = 1
AS
BEGIN
	-- make sure that the caller is dbo or @role
	IF ( IS_MEMBER(@role) != 1 AND USER_ID() != 1)
	BEGIN
		IF (@raiserror = 1)
		BEGIN
			RAISERROR(15003, -1, -1, @role);
		END
		RETURN 15003;
	END
	
	RETURN 0;
END

GO
