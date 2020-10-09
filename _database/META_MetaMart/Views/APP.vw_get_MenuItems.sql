SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [APP].[vw_get_MenuItems] AS
SELECT headings.MenuItemID AS HeadingID,
	   headings.MenuItemName AS HeadingName,
	   items.MenuItemID,
	   items.MenuItemName,
	   items.MenuItemNavTo,
	   headings.SortOrder AS HeadingSortOrder,
	   items.SortOrder AS MenuItemSortOrder
	   --itemscount.MenuItemCount
  FROM APP.MenuItem headings
	   INNER JOIN APP.MenuItem items ON
			items.MenuItemParentID = headings.MenuItemID
	  -- INNER JOIN (SELECT MenuItemParentID AS HeadingID,
			--			  COUNT(1) AS MenuItemCount
			--	     FROM APP.MenuItem
			--	    WHERE MenuItemParentID IS NOT NULL
			--	   GROUP BY MenuItemParentID
			--	  ) itemscount ON
			--itemscount.HeadingID = headings.MenuItemID
 WHERE headings.IsHeaderItem = 1 AND
	   items.IsHeaderItem = 0

GO
