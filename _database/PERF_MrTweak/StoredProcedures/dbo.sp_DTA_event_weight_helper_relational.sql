SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 create procedure [dbo].[sp_DTA_event_weight_helper_relational]
			@SessionID		int
			as
			begin	select "Event String"= EventString, "Weight" = CAST(EventWeight as decimal(38,2)) 	from [MrTweak].[dbo].[DTA_reports_query]
					where SessionID=@SessionID and EventWeight>0
					order by EventWeight desc  end 

GO
