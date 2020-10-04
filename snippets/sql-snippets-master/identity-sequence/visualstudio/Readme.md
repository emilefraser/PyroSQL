# SQL Delta Scripts for Visual Studio and SQL Server Management Studio

## Installation - SQL Server Management Studio

To install in SSMS, you must first determine where your local snippets are stored.

This can be done by opening "Tools" -> "Code Snippets Manager..." and looking at the location for "My Code Snippets". This will likely take the form "%userprofile%\Documents\Visual Studio x\Code Snippets\SQL\My Code Snippets".

Place the .snippet files in this folder.

From now on, you can select the snippets by using the shortcut Ctrl+K,X and selecting the appropriate snippet from the My Code Snippets folder.

## Installation - Visual Studio

To install in Visual Studio, you must first determine where your local snippets are stored.

Note that if you have both Visual Studio and SSMS installed you will have 2 locations for SQL snippets.

Find the location by opening "Tools" -> "Code Snippets Manager..." then selecting the language "Microsoft SQL Server Data Tools, T-SQL Language Service" and looking at the location for "My Code Snippets".

This will likely point to "%userprofile%\Documents\Visual Studio x\Code Snippets\SQL_SSDT\My Code Snippets".

If you have already installed the snippets for SSMS, you can use the "Add..." button to add the existing snippets folder into Visual Studio. Otherwise, you can use the same process of creating the folder and copying the contents as specified above.

As with SSMS, to use the snippets you can use the shortcut Ctrl+K,X and selecting the appropriate snippet from the My Code Snippets folder.

## Notes

* Unlike Atom and Notepad++, the shortcut doesn't appear to work for SQL snippets, so typing 'checkidentity' and using tab to add the rest of the snippet does not work.
* As Visual Studio and SQL Server Management Studio are oriented towards dealing with just SQL Server, the -ms suffix seen in the snippets for the other editors is not present here.