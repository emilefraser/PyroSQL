# SQL Snippets

SQL code snippets to make database life easier

## Editors

There are snippet files for the following editors

* [Atom](https://atom.io/) 
* [Notepad++](https://notepad-plus-plus.org/)
* [SQL Server Management Studio (SSMS)](https://msdn.microsoft.com/en-us/library/mt238290.aspx). Note that snippets were not introduced into SSMS until the 2012 version (version 11.0)
* [Visual Studio](https://www.visualstudio.com/)

Note that for Atom, it will be necessary to edit the snippets.cson file manually and import the snippets from the appropriate .cson file within this repository.

## delta-scripts

This folder has scripts to simplify the creation of delta scripts for creating and updating databases.

The following snippets are available:

| Name | Description | Shortcut |
| --- | --- | --- |
| Add Column | If a column does not exist in the table, add it | addcolumn |
| Add Column Constraint | If a constraint does not exists on the specified column does not exist in the table, add it | addcolumnconstraint |
| Create Stored Procedure | Create the specified stored procedure | createstoredproc |
| Create Table | If the specified table does not exist in the database, create it | createtable |
| Create View | If the specified view does not exist in the table, create it. If it does exist, drop it and recreate it | createview |
| Delete Row | Check to see if a row (and only 1) matching the specified column value exists, if so delete it. | deleterow |
| Drop Column | If the specified column exists on the table, drop it | dropcolumn |
| Drop Column Constraint | If a column does not exist in the table, add it | dropcolumnconstraint |
| Drop Table | If the specified table exists, drop it | droptable |
| Drop View  | If the specified view exists, drop it | dropview |
| Insert Row | Check to see if an entry matching the specified column value exists. If not, insert the specified row | insertrow |
| Make Column Non-Null | Make an existing column non-null. Note that you need to know the existing definition of the column | makenonnull |

### delta-scripts: General notes

The scripts take advantage of the INFORMATION_SCHEMA schema common to SQL Server, MySQL and PostgreSQL, however the implementations use logic which does not necessarily work across databases.

## identity-sequence

This folder has scripts for dealing with sequences and identity columns.

The following snippets are available:

| Name | Description | Shortcut |
| ---- | ----------- | -------- |
| Check Identity | Find out what the current identity value for the specified table is | checkidentity |
| Reset Identity | Reseeds the specified identity counter | resetidentity |

