SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE VIEW sysproxyloginsubsystem_view
AS
SELECT ps.subsystem_id AS subsystem_id, pl.proxy_id AS proxy_id, pl.sid AS sid, pl.flags AS flags
FROM sysproxylogin pl JOIN sysproxysubsystem ps ON pl.proxy_id = ps.proxy_id

GO
