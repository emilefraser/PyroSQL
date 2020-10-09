SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2018-09-11
-- Description:	Materialized SP of REPREG.sp_rpt_ReportStatus
-- =============================================
CREATE PROCEDURE [REPREG].[sp_mat_ReportInfo] 
	@ReportID as varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Create temp table for sp result set
	CREATE TABLE [dbo].[#ReportStatus](
		[Name] [varchar](200) NULL,
		[Description] [varchar](5000) NULL,
		[ErrorParagraph] [varchar](500) NULL,
		[ReportStatus] [varchar](50) NULL,
		[ReportStatusIndicator] [varbinary](max) NULL,
		[DataLastRefreshedOn] [datetime] NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

	--Execute sp and populate the temp table
	INSERT INTO #ReportStatus
	execute REPREG.sp_rpt_ReportInfo @ReportID;

	--Select the temp table result set and rename columns
	SELECT	[Name] as [Report Name]
			,[Description] as [Report Description]
			,[ErrorParagraph] as [Report Status Description]
			,[ReportStatus] as [Report Status Identifier]
			,[ReportStatusIndicator] as [Report Status Picture]
			,[DataLastRefreshedOn] as [Last Refreshed On]
	from	#ReportStatus


	-- Garbage Collection
	drop table #ReportStatus

END

GO
