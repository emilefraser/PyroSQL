SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW dbo.dbo_vw_transaction AS
select
id,
lag(id) over (partition by AccountID order by id asc) lag_id,
lead(id) over (partition by AccountID order by id asc) lead_id,
expire
from trans;

GO
