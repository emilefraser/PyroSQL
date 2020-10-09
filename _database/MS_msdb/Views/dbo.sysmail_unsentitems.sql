SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE VIEW sysmail_unsentitems
AS
SELECT * FROM msdb.dbo.sysmail_allitems WHERE (sent_status = 'unsent' OR sent_status = 'retrying')


GO
