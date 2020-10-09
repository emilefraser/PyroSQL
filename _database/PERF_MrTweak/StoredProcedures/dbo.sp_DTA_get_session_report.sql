SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_get_session_report] 
	@SessionID int, 
	@ReportID int,
	@ReportType int
as 
begin

	declare @retval  int							
	set nocount on

	exec @retval =  sp_DTA_check_permission @SessionID

	if @retval = 1
	begin
		raiserror(31002,-1,-1)
		return(1)
	end	
	
	if @ReportType = 0
	begin
		/**************************************************************/
		/* Query Cost Report                                          */
		/**************************************************************/
		if @ReportID = 2
		begin
			exec sp_DTA_query_cost_helper_relational @SessionID	
		end
		/**************************************************************/
		/* Event Frequency Report                                     */
		/**************************************************************/
		else if @ReportID = 3
		begin
			exec sp_DTA_event_weight_helper_relational @SessionID								
		end	
		/**************************************************************/
		/* Query Detail Report                                        */
		/**************************************************************/
		else if @ReportID = 4
		begin
			exec sp_DTA_query_detail_helper_relational  @SessionID	
		end	
		/**************************************************************/
		/* Current Query Index Relations Report                        */
		/**************************************************************/
		else if @ReportID = 5
		begin
			exec sp_DTA_query_indexrelations_helper_relational  @SessionID,0
		end	
		/**************************************************************/
		/* Recommended Query Index Relations Report                   */
		/**************************************************************/
		else if @ReportID = 6
		begin
			exec sp_DTA_query_indexrelations_helper_relational  @SessionID,1
		end	
		/**************************************************************/
		/* Current Query Cost Range		                             */
		/**************************************************************/
		else if @ReportID = 7
		begin
			exec sp_DTA_query_costrange_helper_relational @SessionID
		end
		/**************************************************************/
		/* Recommended Query Cost Range		                            */
		/**************************************************************/
		else if @ReportID = 8
		begin
			exec sp_DTA_query_costrange_helper_relational @SessionID
		end
		/**************************************************************/
		/* Current Query Index Usage Report		                       */
		/**************************************************************/
		else if @ReportID = 9
		begin
			exec sp_DTA_index_usage_helper_relational @SessionID,0
		end
		/**************************************************************/
		/* Recommended Query Index Usage Report		                   */
		/**************************************************************/
		else if @ReportID = 10
		begin
			exec sp_DTA_index_usage_helper_relational @SessionID,1
		end
		/**************************************************************/
		/* Current Index Detail Report                                */
		/**************************************************************/
		else if @ReportID = 11
		begin
			exec sp_DTA_index_detail_current_helper_relational  @SessionID
		end	
		/**************************************************************/
		/* Recommended Index Detail Report                                */
		/**************************************************************/
		else if @ReportID = 12
		begin
			exec sp_DTA_index_detail_recommended_helper_relational  @SessionID
		end	
		/**************************************************************/
		/* View Table Relations Report                                */
		/**************************************************************/
		else if @ReportID = 13
		begin
			exec sp_DTA_view_table_helper_relational  @SessionID
		end
		/**************************************************************/
		/* Workload Analysis Report                                   */
		/**************************************************************/
		else if @ReportID = 14
		begin
			exec sp_DTA_wkld_analysis_helper_relational @SessionID
		end	
		/**************************************************************/
		/* All object access reports                                   */
		/**************************************************************/
		else if @ReportID = 15
		begin
			exec sp_DTA_database_access_helper_relational @SessionID
		end
		else if @ReportID = 16
		begin
			exec sp_DTA_table_access_helper_relational @SessionID
		end
		else if @ReportID = 17
		begin
			exec sp_DTA_column_access_helper_relational @SessionID
		end
	end
	-- XML Reports
	else if @ReportType = 1
	begin
		/**************************************************************/
		/* Query Cost Report                                          */
		/**************************************************************/
		if @ReportID = 2
		begin
			exec sp_DTA_query_cost_helper_xml @SessionID	
		end
		/**************************************************************/
		/* Event Frequency Report                                     */
		/**************************************************************/
		else if @ReportID = 3
		begin
			exec sp_DTA_event_weight_helper_xml @SessionID								
		end	
		/**************************************************************/
		/* Query Detail Report                                        */
		/**************************************************************/
		else if @ReportID = 4
		begin
			exec sp_DTA_query_detail_helper_xml  @SessionID	
		end	
		/**************************************************************/
		/* Current Query Index Relations Report                        */
		/**************************************************************/
		else if @ReportID = 5
		begin
			exec sp_DTA_query_indexrelations_helper_xml  @SessionID,0
		end	
		/**************************************************************/
		/* Recommended Query Index Relations Report                   */
		/**************************************************************/
		else if @ReportID = 6
		begin
			exec sp_DTA_query_indexrelations_helper_xml  @SessionID,1
		end	
		/**************************************************************/
		/* Current Query Cost Range		                             */
		/**************************************************************/
		else if @ReportID = 7
		begin
			exec sp_DTA_query_costrange_helper_xml @SessionID
		end
		/**************************************************************/
		/* Recommended Query Cost Range		                            */
		/**************************************************************/
		else if @ReportID = 8
		begin
			exec sp_DTA_query_costrange_helper_xml @SessionID
		end
		/**************************************************************/
		/* Current Query Index Usage Report		                       */
		/**************************************************************/
		else if @ReportID = 9
		begin
			exec sp_DTA_index_usage_helper_xml @SessionID,0
		end
		/**************************************************************/
		/* Recommended Query Index Usage Report		                   */
		/**************************************************************/
		else if @ReportID = 10
		begin
			exec sp_DTA_index_usage_helper_xml @SessionID,1
		end
		/**************************************************************/
		/* Current Index Detail Report                                */
		/**************************************************************/
		else if @ReportID = 11
		begin
			exec sp_DTA_index_current_detail_helper_xml  @SessionID
		end	
		/**************************************************************/
		/* Recommended Index Detail Report                                */
		/**************************************************************/
		else if @ReportID = 12
		begin
			exec sp_DTA_index_recommended_detail_helper_xml  @SessionID
		end	
		/**************************************************************/
		/* View Table Relations Report                                */
		/**************************************************************/
		else if @ReportID = 13
		begin
			exec sp_DTA_view_table_helper_xml  @SessionID
		end
		/**************************************************************/
		/* Workload Analysis Report                                   */
		/**************************************************************/
		else if @ReportID = 14
		begin
			exec sp_DTA_wkld_analysis_helper_xml @SessionID
		end	
		/**************************************************************/
		/* All object access reports                                   */
		/**************************************************************/
		else if @ReportID = 15
		begin
			exec sp_DTA_database_access_helper_xml @SessionID
		end
		else if @ReportID = 16
		begin
			exec sp_DTA_table_access_helper_xml @SessionID
		end
		else if @ReportID = 17
		begin
			exec sp_DTA_column_access_helper_xml @SessionID
		end
	end		
end	

GO
