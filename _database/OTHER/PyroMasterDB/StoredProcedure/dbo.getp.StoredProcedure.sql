SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[getp] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB get property value
declare @value varchar(255) 
exec betl.dbo.getp 'log_level', @Value output 
print 'loglevel' + isnull(@Value,'?')
select * from dbo.prop_ext
*/
ALTER   PROCEDURE [dbo].[getp] 
	@prop varchar(255)
	, @value varchar(255) output 
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine scope 
  declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 0 -- set to 1 to debug this proc
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ? ?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @property_scope = property_scope , @prop_id = property_id
  from static.Property
  where [property_name]=@prop
  if @debug = 1 
   	  exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Property scope ?', @i1 =@property_scope, @simple_mode = 1
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
  if @property_scope = 'user' -- then we need an obj_id 
  begin
	set @full_obj_name =  suser_sname()
  end
  
  --select @obj_id = dbo.obj_id(@full_obj_name, null) 
  select @obj_id = dbo.obj_id(@full_obj_name, null ) 
  if @debug = 1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Lookup ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
  -- exec dbo.get_obj_id @full_obj_name, @obj_id output, @property_scope=DEFAULT, @recursive_depth=DEFAULT, @transfer_id=@transfer_id
  if @obj_id  is null 
  begin 
	if @property_scope = 'user' -- then create obj_id 
	begin
		insert into dbo.Obj (obj_type_id, obj_name) 
		values (60, @full_obj_name)
			
		select @obj_id = dbo.obj_id(@full_obj_name, null) 
	    if @debug = 1 
		  exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Created object ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1

	end
	else 
	begin
		if @debug = 1 
			exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='object not found ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
		goto footer
	end
  end
  
  select @value = isnull(value,default_value) from dbo.Prop_ext
  where property = @prop  and obj_id = @obj_id 
  if @debug = 1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='property value ?(?) ', @i1 =@prop, @i2=@value ,  @simple_mode = 1
  footer:
  if @debug=1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='DONE ? ? ?->?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @i4=@value, @simple_mode = 1
  -- END standard BETL footer code... 
end

GO
