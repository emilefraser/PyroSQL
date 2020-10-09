SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [APP].[vw_get_MenuItemHeadings] AS
SELECT headings.MenuItemID AS MenuItemHeadingID,
	   headings.MenuItemName AS HeadingName,
	   headings.SortOrder AS HeadingSortOrder
  FROM APP.MenuItem headings
 WHERE headings.IsHeaderItem = 1

GO
