

CREATE FUNCTION [DSQLT].[ColumnCompare]
(@Source NVARCHAR (MAX), @Target NVARCHAR (MAX), @SourceAlias NVARCHAR (MAX), @TargetAlias NVARCHAR (MAX))
RETURNS 
    @Result TABLE (
        [Column]                    NVARCHAR (MAX) NOT NULL,
        [ColumnQ]                   NVARCHAR (MAX) NOT NULL,
        [SourceColumnQ]             NVARCHAR (MAX) NOT NULL,
        [TargetColumnQ]             NVARCHAR (MAX) NULL,
        [Default_Value]             NVARCHAR (MAX) NULL,
        [Compare_Columns]           NVARCHAR (MAX) NULL,
        [Compare_Columns_With_Null] NVARCHAR (MAX) NULL,
        [Source_Value]              NVARCHAR (MAX) NULL,
        [Source_Value_With_Null]    NVARCHAR (MAX) NULL,
        [Target_Value]              NVARCHAR (MAX) NULL,
        [Target_Value_With_Null]    NVARCHAR (MAX) NULL,
		[Source_Concatvalue]		NVARCHAR (MAX) NULL,
		[Target_Concatvalue]		NVARCHAR (MAX) NULL,
		[is_primary_key]			bit NOT NULL,
		[is_Source_nullable]		bit NOT NULL,
		[is_Target_nullable]		bit NOT NULL,
		[is_Sync_Column]			bit NOT NULL,
		[in_both_Tables]			bit NOT NULL,
		[Order]						int NOT NULL,
		[Source_Type]				[sysname] NOT NULL,
		[Target_Type]				[sysname] NULL, 
		[Source_Type_Id]			[tinyint] NOT NULL,
		[Target_Type_Id]			[tinyint] NULL,
		[Source_Length]				[smallint] NOT NULL,
		[Target_Length]				[smallint] NULL,
		[Source_Precision]			[tinyint] NOT NULL,
		[Target_Precision]			[tinyint] NULL,
		[Source_Scale]				[tinyint] NOT NULL,
		[Target_Scale]				[tinyint] NULL
)
AS
BEGIN

--declare @Source NVARCHAR (MAX)
--declare @Target NVARCHAR (MAX)
--declare @SourceAlias NVARCHAR (MAX)
--declare @TargetAlias NVARCHAR (MAX)

--set @Source='Source.[Production.Product]'
--set @Target='Target.[Production.Product]'
--set @SourceAlias='S'
--set @TargetAlias='T'

--SELECT * FROM DSQLT.[ColumnCompare] (
--'Source.[Production.Product]'
--,'Target.[Production.Product]'
--,'S'
--,'T'
--)

SET @Source=DSQLT.QuoteNameSB(@Source)
SET @Target=DSQLT.QuoteNameSB(@Target)

IF LEN(@SourceAlias) > 0
	SET @SourceAlias=DSQLT.QuoteNameSB(@SourceAlias)+'.'
IF @SourceAlias is null
	SET @SourceAlias=@Source+'.'
IF LEN(@TargetAlias) > 0
	SET @TargetAlias=DSQLT.QuoteNameSB(@TargetAlias)+'.'
IF @TargetAlias is null
	SET @TargetAlias=@Target+'.'

INSERT @Result
select 
 S.[Column]
,S.[ColumnQ]
,@SourceAlias+S.ColumnQ
,@TargetAlias+T.ColumnQ
,ST.type_default as [Default_Value]

,'( ' 
	+ case 
		when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241  -- XML grundsätzlich in nvarchar umwandeln
												--, um Unverträglichkeiten von Collations zu vermeiden
			and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
		then @SourceAlias+S.ColumnQ
		else
			DSQLT.TypePattern(
					ST.type_comparison
				,	@SourceAlias+S.ColumnQ
				,	ST.type_name
				,	case when S.Length < T.Length then S.Length else T.Length end 
				,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
				,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
			 ) 
		end
	+ ' <> '
	+ case 
		when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241  -- XML grundsätzlich in nvarchar umwandeln
												--, um Unverträglichkeiten von Collations zu vermeiden
			and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
		then @TargetAlias+T.ColumnQ
		else
			DSQLT.TypePattern(
					TT.type_comparison
				,	@TargetAlias+T.ColumnQ
				,	TT.type_name
				,	case when S.Length < T.Length then S.Length else T.Length end 
				,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
				,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
			) 
		end
	+ ' or ('+@SourceAlias+S.ColumnQ+' is null and '+@TargetAlias+T.ColumnQ+' is not null)'
	+ ' or ('+@SourceAlias+S.ColumnQ+' is not null and '+@TargetAlias+T.ColumnQ+' is null)'
	+ ' )'
	as Compare_Columns
	
,	DSQLT.TypePattern(
			ST.type_comparison
		,	'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
	) 
	+ ' <> '
	+ DSQLT.TypePattern(
			TT.type_comparison
		,	'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
	) 
	as Compare_Columns_With_Null
	
,case 
	when S.[Type_Id]=T.[Type_Id]  and S.[Type_Id] <>241
		and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale
	then @SourceAlias+S.ColumnQ
	else
		DSQLT.TypePattern(
			ST.type_comparison
		,	@SourceAlias+S.ColumnQ
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Source_Value
	
,case 
	when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241
				and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
	then 'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
	else
		DSQLT.TypePattern(
			ST.type_comparison
		,	'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Source_Value_With_Null
	
,case 
	when S.[Type_Id]=T.[Type_Id]  and S.[Type_Id] <>241
		and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale
	then @TargetAlias+T.ColumnQ
	else
		DSQLT.TypePattern(
			TT.type_comparison
		,	@TargetAlias+T.ColumnQ
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Target_Value
	
,case 
	when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241
				and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
	then 'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
	else
		DSQLT.TypePattern(
			TT.type_comparison
		,	'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Target_Value_With_Null
	
,Replace(ST.type_concatvalue,'%v',@SourceAlias+S.ColumnQ) as Source_concatvalue
,Replace(TT.type_concatvalue,'%v',@TargetAlias+T.ColumnQ) as Target_concatvalue
,isnull(T.is_primary_key,S.is_primary_key) as is_primary_key
,S.is_nullable as is_Source_nullable
,isnull(T.is_nullable,1) as is_Target_nullable
,case when X.Name is null then 0 else 1 end as is_Sync_Column
,case when T.Name is null then 0 else 1 end as in_both_Tables
,S.[Order] as [Order]
,S.[Type]
,T.[Type]
,S.[Type_Id]
,T.[Type_Id]
,S.[Length]
,T.[Length]
,S.[Precision]
,T.[Precision]
,S.[Scale]
,T.[Scale]
from DSQLT.Columns(@Source) S 
left outer join DSQLT.Types ST on ST.type_id=S.[Type_Id]
left outer join DSQLT.Columns(@Target) T on S.Name=T.Name
left outer join DSQLT.Types TT on TT.type_id=T.[Type_Id]
left outer join DSQLT.Columns('DSQLT.Sync_Template') X on S.Name=X.Name

RETURN
END