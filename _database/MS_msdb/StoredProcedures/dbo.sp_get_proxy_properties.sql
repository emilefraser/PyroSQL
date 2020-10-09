SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_get_proxy_properties
	@proxy_id [int] = NULL,  -- specify either @current_proxy_id or @current_proxy_name ; if both are specified as null, propery for all proxies are returned back
	@proxy_name [sysname] = NULL
AS
BEGIN
    DECLARE @retval   INT
    SET NOCOUNT ON

	-- Validate only if either proxy name or proxy id was specified
    IF NOT (@proxy_id IS NULL ) AND (@proxy_name IS NULL)
	BEGIN
		EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                 '@proxy_id',
                                                 @proxy_name OUTPUT,
                                                 @proxy_id   OUTPUT

		IF (@retval <> 0)
		BEGIN
			-- exception message was raised inside sp_verify_proxy_identifiers; we dont need to RAISERROR again here
			RETURN(1) -- Failure
		END
	END

    -- return domain name, user name, credential id; used by SQL agent to query for proxy
	SELECT CASE CHARINDEX(N'\', c.credential_identity)
		WHEN 0 THEN  NULL
		ELSE LEFT(c.credential_identity, CHARINDEX(N'\', c.credential_identity)-1)
		END
		AS user_domain,
	RIGHT(c.credential_identity, LEN(c.credential_identity)- CHARINDEX(N'\', c.credential_identity)) AS user_name,
	c.credential_id
	FROM msdb.dbo.sysproxies p JOIN
	sys.credentials c
	ON p.credential_id = c.credential_id
	WHERE (p.proxy_id = @proxy_id OR @proxy_id IS NULL)

END

GO
