SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019-01-08
-- Description: Generate DDL statements from DMOD.LoadConfig table list and insert into DDL Execution Queue
-- =============================================

--Sample execution

/*

exec [DMOD].[sp_generate_ddl_LoadStoredProcs]

--*/

CREATE PROCEDURE [DMOD].[sp_generate_ddl_LoadStoredProcs_TOBEDELETED] 
	@LoadConfigID int

AS
	
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON


	--======================================================================================================================
	--Variable declerations
	declare @SourceDataEntityID int = NULL
			, @TargetDataEntityID int = NULL
			, @SourceSystemAbbreviation varchar(50) = NULL
			, @LoadTypeID int = NULL
			, @DropStatement varchar(max) = NULL
			, @ProcStatement nvarchar(max)
		--------------------------------------------------------------------------------------------------------------------
		--/*
		-- Testing variables (comment out after use and testing)
		--declare @LoadConfigID int = 1
		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================
	
	--======================================================================================================================
	--Get list of tables that are configured in DMOD.LoadConfig
	--======================================================================================================================

	select	@SourceDataEntityID = SourceDataEntityID
			, @TargetDataEntityID = TargetDataEntityID
			, @LoadTypeID = LoadTypeID
			, @SourceSystemAbbreviation = DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(TargetDataEntityID)
	from	DMOD.LoadConfig
	where	LoadConfigID = @LoadConfigID

	--select @TargetDataEntityID, @SourceDataEntityID
	--======================================================================================================================
	--
	--======================================================================================================================
	
	--select	DataEntityName
	--		, SystemAbbreviation
	--from	DC.vw_rpt_DatabaseFieldDetail
	--where	DataEntityID = @TargetDataEntityID

	--======================================================================================================================
	-- Generate drop statement for load proc
	--======================================================================================================================
	select	@DropStatement =
				CONVERT(varchar(max), 'IF EXISTS (select p.name from sys.procedures p inner join sys.schemas s on s.schema_id = p.schema_id where p.name = ''sp_' 
										+ ltype.LoadTypeCode + '_' 
										+ @SourceSystemAbbreviation + '_' 
										+ dctarget.DataEntityName + ''' and s.name = ''' 
										+ @SourceSystemAbbreviation +''')' + CHAR(13) + CHAR(10) 
										+ 'DROP PROCEDURE ' + @SourceSystemAbbreviation 
										+ '.sp_' + ltype.LoadTypeCode +'_'+ @SourceSystemAbbreviation +'_' + dctarget.DataEntityName )
	--select	dcsource.*
	from	DMOD.LoadConfig lconfig
		inner join DMOD.LoadType ltype on lconfig.LoadTypeID = ltype.LoadTypeID
		inner join 
					(
						select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
						from	DC.vw_rpt_DatabaseFieldDetail 
						where	DataEntityID = @SourceDataEntityID
					) dcsource on lconfig.SourceDataEntityID = dcsource.DataEntityID
		inner join 
					(
						select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
						from	DC.vw_rpt_DatabaseFieldDetail 
						where	DataEntityID = @TargetDataEntityID
					) dctarget on lconfig.TargetDataEntityID = dctarget.DataEntityID
	where	LoadConfigID = @LoadConfigID

	select @DropStatement

	--======================================================================================================================
	-- Generate create procedure statement
	--======================================================================================================================
	--select	
	--			REPLACE(
	--				REPLACE(
	--					REPLACE(
	--						REPLACE(
	--							REPLACE(ParameterisedTemplateScript, '~@TableName~', dcsource.DataEntityName)
	--											,'~@SourceSystemAbbr~', dcsource.SystemAbbreviation)
	--											, '~@CreateTableFieldList~', (select [DC].[udf_FieldListForCreateTable](SourceDataEntityID)))
	--											, '~@FieldListNoAlias~', (select [DC].[udf_FieldListForSelect](SourceDataEntityID)))
	--											, '~@FieldListWithAlias~', (select [DC].[udf_FieldListForSelectWithAlias](SourceDataEntityID)))
	--from    DMOD.LoadConfig lconfig
	--	inner join DMOD.LoadType ltype on ltype.LoadTypeID = lconfig.LoadConfigID
	--	inner join 
	--				(
	--					select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
	--					from	DC.vw_rpt_DatabaseFieldDetail 
	--					where	DataEntityID = @SourceDataEntityID
	--				) dcsource on lconfig.SourceDataEntityID = dcsource.DataEntityID
	--	inner join 
	--				(
	--					select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
	--					from	DC.vw_rpt_DatabaseFieldDetail 
	--					where	DataEntityID = @TargetDataEntityID
	--				) dctarget on lconfig.TargetDataEntityID = dctarget.DataEntityID
	--where	LoadConfigID = @LoadConfigID

	DECLARE sqlcursor CURSOR FOR   
		select	
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(ParameterisedTemplateScript, '~@TableName~', dcsource.DataEntityName)
												,'~@SourceSystemAbbr~', @SourceSystemAbbreviation)
												, '~@CreateTableFieldList~', (select [DC].[udf_FieldListForCreateTable](SourceDataEntityID)))
												, '~@FieldListNoAlias~', (select [DC].[udf_FieldListForSelect](SourceDataEntityID)))
												, '~@FieldListWithAlias~', (select [DC].[udf_FieldListForSelectWithAlias](SourceDataEntityID)))
		from    DMOD.LoadConfig lconfig
			inner join DMOD.LoadType ltype on ltype.LoadTypeID = lconfig.LoadConfigID
			inner join 
						(
							select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
							from	DC.vw_rpt_DatabaseFieldDetail 
							where	DataEntityID = @SourceDataEntityID
						) dcsource on lconfig.SourceDataEntityID = dcsource.DataEntityID
			inner join 
						(
							select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
							from	DC.vw_rpt_DatabaseFieldDetail 
							where	DataEntityID = @TargetDataEntityID
						) dctarget on lconfig.TargetDataEntityID = dctarget.DataEntityID
		where	LoadConfigID = @LoadConfigID
		
		--where	TableName = 'DEPARTMENT'

	OPEN sqlcursor  

	FETCH NEXT FROM sqlcursor   
	INTO  @ProcStatement 

	declare @i int = 0

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		--SELECT @DropStatement
		SELECT @ProcStatement
		--EXEC (@DropStatement)
		--EXEC (@ProcStatement)
	
		WHILE @i < LEN(@ProcStatement)
		BEGIN
			SELECT SUBSTRING(@ProcStatement, @i, @i + 8000)
			select @i += 8000
		END

		FETCH NEXT FROM sqlcursor   
		INTO @ProcStatement 
	END   

	CLOSE sqlcursor;  
	DEALLOCATE sqlcursor;

	--======================================================================================================================
	--
	--======================================================================================================================

GO
