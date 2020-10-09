SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE VIEW sysmail_sentitems
AS
SELECT * FROM msdb.dbo.sysmail_allitems WHERE sent_status = 'sent'


GO
