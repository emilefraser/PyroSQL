
CREATE PROCEDURE [DSQLT].[_iterateTemplate]
@Cursor CURSOR VARYING OUTPUT
, @p1 NVARCHAR (MAX)=null
, @p2 NVARCHAR (MAX)=null
, @p3 NVARCHAR (MAX)=null
, @p4 NVARCHAR (MAX)=null
, @p5 NVARCHAR (MAX)=null
, @p6 NVARCHAR (MAX)=null
, @p7 NVARCHAR (MAX)=null
, @p8 NVARCHAR (MAX)=null
, @p9 NVARCHAR (MAX)=null
, @Database NVARCHAR (MAX)=null
, @Template NVARCHAR (MAX)=null OUTPUT
, @Create NVARCHAR (MAX)=null
, @CreateParam NVARCHAR (MAX)=''
, @UseTransaction bit = 0
, @Once BIT=0
, @Print BIT=0
AS
Begin
DECLARE @TemplateConcat nvarchar(max)
DECLARE @Temp nvarchar(max)
DECLARE @TempCreate nvarchar(max)
DECLARE @TempDatabase nvarchar(max)
DECLARE @OrgDatabase nvarchar(max)
DECLARE @c1 nvarchar(max)
DECLARE @c2 nvarchar(max)
DECLARE @c3 nvarchar(max) 
DECLARE @c4 nvarchar(max)
DECLARE @c5 nvarchar(max)
DECLARE @c6 nvarchar(max)
DECLARE @c7 nvarchar(max)
DECLARE @c8 nvarchar(max)
DECLARE @c9 nvarchar(max)
DECLARE	@Count int

set @TemplateConcat ='' 
set @Temp  ='' 
set @TempCreate  ='' 
set	@Count = 0
set @OrgDatabase=@Database

open @Cursor
while (1=1)
begin
	if @count=0
	BEGIN  -- feststellen der Anzahl Spalten, die vom Cursor zurückgeliefert werden
		begin try 
			set @count=1
			fetch first from @Cursor into @c1
			SET @c2=@p1
			SET @c3=@p2
			SET @c4=@p3
			SET @c5=@p4
			SET @c6=@p5
			SET @c7=@p6
			SET @c8=@p7
			SET @c9=@p8
			continue
		end try 
		begin catch
			set @count=2
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2
			SET @c3=@p1
			SET @c4=@p2
			SET @c5=@p3
			SET @c6=@p4
			SET @c7=@p5
			SET @c8=@p6
			SET @c9=@p7
			continue
		end try 
		begin catch
			set @count=3
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3
			SET @c4=@p1
			SET @c5=@p2
			SET @c6=@p3
			SET @c7=@p4
			SET @c8=@p5
			SET @c9=@p6
			continue
		end try 
		begin catch
			set @count=4
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4
			SET @c5=@p1
			SET @c6=@p2
			SET @c7=@p3
			SET @c8=@p4
			SET @c9=@p5
			continue
		end try 
		begin catch
			set @count=5
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5
			SET @c6=@p1
			SET @c7=@p2
			SET @c8=@p3
			SET @c9=@p4
			continue
		end try 
		begin catch
			set @count=6
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
			SET @c7=@p1
			SET @c8=@p2
			SET @c9=@p3
			continue
		end try 
		begin catch
			set @count=7
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
			SET @c8=@p1
			SET @c9=@p2
			continue
		end try 
		begin catch
			set @count=8
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
			SET @c9=@p1
			continue
		end try 
		begin catch
			set @count=9
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
			continue
		end try 
		begin catch
		print @count
			-- Spaltenanzahl nicht zwischen 1 und 9
		end catch
		Break  -- erfolglos
	END
	IF (@@FETCH_STATUS <> 0) break  -- alle Datensätze geholt
	
	set @Database=@OrgDatabase
		-- Parameterersetzung für Datenbanknamen
	exec DSQLT._fillDatabaseTemplate  @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database=@Database OUTPUT

	SET @Temp=@Template 
	IF @Once=0  -- jedesmal mit Transaktion umfassen
		exec [DSQLT].[_addTransaction] 	@Temp OUTPUT,@Database,@UseTransaction

	-- Prozedurrumpf mit DDL umfassen, falls Create 
	-- wichtig: generell Parameterersetzung wie bei Template
	if @Create is not null and (@Once=0 or @TempCreate='')  -- bei once=0 ODER beim ersten Mal
		BEGIN
		SET @TempDatabase=@Database
		SET @TempCreate=@Create 
		exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@TempCreate OUTPUT
		if @Once=0	-- dann wird je Iteration eine Stored Proc generiert
			exec DSQLT._addCreateStub @Temp OUTPUT,@Database,@TempCreate
		END
		
	exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@Temp OUTPUT

	-- ausführen oder verketten
	IF @Once=0  -- ausführen / drucken
		exec DSQLT._doTemplate @Database,@Temp,@Print
		
	-- immer verketten, stört nicht
	SET @TemplateConcat=@TemplateConcat+@Temp+DSQLT.CRLF()

	IF @Count = 1 fetch next from @Cursor into @c1
	IF @Count = 2 fetch next from @Cursor into @c1,@c2
	IF @Count = 3 fetch next from @Cursor into @c1,@c2,@c3
	IF @Count = 4 fetch next from @Cursor into @c1,@c2,@c3,@c4
	IF @Count = 5 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5
	IF @Count = 6 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
	IF @Count = 7 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
	IF @Count = 8 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
	IF @Count = 9 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
end
close @Cursor
--deallocate @Cursor

--  ausführen, falls einmalig
if @Once=1
	BEGIN
	exec [DSQLT].[_addTransaction] 	@TemplateConcat OUTPUT,@Database,@UseTransaction
	IF @Create is not null  -- einmalig Prozedurrumpf
		exec DSQLT._addCreateStub @TemplateConcat OUTPUT,@TempDatabase,@TempCreate
	exec DSQLT._doTemplate @TempDatabase,@TemplateConcat,@Print
	END

-- Rückgabe der Verkettung
SET @Template =@TemplateConcat
	
end




