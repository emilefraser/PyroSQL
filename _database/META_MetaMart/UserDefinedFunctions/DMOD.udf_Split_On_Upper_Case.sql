SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE Function [DMOD].[udf_Split_On_Upper_Case](@Temp VarChar(1000))
Returns VarChar(1000)
AS
BEGIN
--Declare @Temp VARCHAR(100) = 'FieldID'
Declare @KeepValues as varchar(50)
SET @KeepValues = '%[^ ][ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'

    IF ((select 1 from TYPE.GenericFriendlyName where FieldName = @Temp) = 1)
        BEGIN
            SET @Temp = (select FriendlyName FROM TYPE.GenericFriendlyName WHERE FieldName = @Temp)    
        END
    ELSE
        BEGIN
            WHILE PatIndex(@KeepValues collate Latin1_General_Bin, @Temp) > 0
                BEGIN
                    SET @Temp = Stuff(@Temp, PatIndex(@KeepValues collate Latin1_General_Bin, @Temp) + 1, 0, ' ')
                END
    END
    --SELECT @Temp
    RETURN @Temp
END



GO
