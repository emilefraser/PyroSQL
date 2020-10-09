SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

create view spt_values as
select name collate database_default as name,
	number,
	type collate database_default as type,
	low, high, status
from sys.spt_values

GO
