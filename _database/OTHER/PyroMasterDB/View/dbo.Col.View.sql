SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Col]'))
EXEC dbo.sp_executesql @statement = N'
	  
CREATE   VIEW [dbo].[Col] AS
	SELECT     * 
	FROM  [dbo].[Col_hist] AS h
	WHERE     (eff_dt =
                      ( SELECT     MAX(eff_dt) max_eff_dt
                        FROM       [dbo].[Col_hist] h2
                        WHERE      h.column_id = h2.column_id
                       )
              )
		AND delete_dt IS NULL 











' 
GO
