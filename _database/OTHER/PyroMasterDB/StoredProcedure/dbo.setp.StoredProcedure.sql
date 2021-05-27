SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[setp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[setp] AS' 
END
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set property value
exec betl.dbo.setp 'log_level', 'debug'
select * from dbo.Prop_ext
*/
ALTER   PROCEDURE [dbo].[setp] 
	@prop varchar(255)
	, @value varchar(255)
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine property_scope 
  declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 0
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @property_scope = property_scope , @prop_id = property_id
  from dbo.Prop_ext
  where [property]=@prop
  if @prop_id is null 
  begin 
	print 'Property not found in static.Property '
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property ? not found in static.Property ', @i1 =@prop, @simple_mode = 1
	goto footer
  end
  if @property_scope is null 
  begin 
	print 'Property scope is not defined in static.Property'
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property scope ? defined in static.Property', @i1 =@prop, @simple_mode = 1
	goto footer
  end

  -- scope is not null 
  if @property_scope = 'user' -- then we need the obj_id of the current user
  begin
	set @full_obj_name = suser_sname()
  end
  exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @scope=DEFAULT, @transfer_id=@transfer_id

  if @obj_id  is null 
  begin 
	if @property_scope = 'user' -- then create obj_id 
	begin
		insert into dbo.Obj (obj_type_id, obj_name) 
		values (60, @full_obj_name)
			
		exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @scope=DEFAULT, @transfer_id=@transfer_id	
	end

	if @obj_id is null 
	begin
		if @debug =1 
			exec dbo.log @transfer_id, 'ERROR', 'object not found ? , property_scope ? ', @full_obj_name , @property_scope
		goto footer
	end 
  end

	if @debug =1 
		exec dbo.log @transfer_id, 'var', 'object ? (?) , property_scope ? ', @full_obj_name, @obj_id , @property_scope 
		
	begin try 
		begin transaction 
			-- delete any existing value. 
			delete from dbo.Property_Value 
			where obj_id = @obj_id and property_id = @prop_id 
			insert into dbo.Property_Value ( property_id, [obj_id], value) 
			values (@prop_id , @obj_id, @value)

			-- invalidate the user cache. So that it gets refreshed next time. 
			update dbo.Cache_user_data set expiration_dt = getdate() 
			where user_name = suser_sname() and expiration_dt  > getdate()  -- only when set in the future

		commit transaction


	end try 
	begin catch
		declare @msg as varchar(4000) 
		set @msg = ERROR_MESSAGE() 
		if @@TRANCOUNT>0 
			rollback transaction
		exec dbo.log @transfer_id, 'ERROR', 'msg ? ', @msg
	end catch 

--	select * from [dbo].[Property_ext]	where obj_id = @obj_id and property like @prop
    footer:
		if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='done ? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL footer code... 
end











GO
