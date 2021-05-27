SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[GetGregorianEasterSunday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [dt].[GetGregorianEasterSunday](@year SMALLINT)
RETURNS TABLE
RETURN
    WITH
    Step1 AS( SELECT a = @year%19, b = FLOOR(1.0*@year/100), c = @year%100 ),
    Step2 AS( SELECT a,b,c,d = FLOOR(1.0*b/4), e=b%4, f=FLOOR((8.0+b)/25) FROM Step1 ),
    Step3 AS( SELECT a,b,c,d,e,g = FLOOR((1.0+ b- f)/3) FROM Step2 ),
    Step4 AS( SELECT a,d,e,h = (19*a+b-d-g+15)%30, i= FLOOR(1.0*c/4), k= @year%4 FROM Step3    ),
    Step5 AS( SELECT a,h,l = (32.0+2*e+2*i-h-k)%7 FROM Step4 ),
    Step6 AS( SELECT h,l,m = FLOOR((1.0*a+11*h+22*l)/451) FROM Step5 ),
    Step7 AS( SELECT easterSunday =
                CAST( DATEADD(dd, (h+l-7*m+114)%31,
                DATEADD(mm, FLOOR((1.0*h+l-7*m+114)/31)-1,
                DATEADD(yy, @year-2000, ''2000-01-01'') )
                ) AS DATE)
        FROM Step6       
        )
    SELECT easterSunday
    FROM Step7
' 
END
GO
