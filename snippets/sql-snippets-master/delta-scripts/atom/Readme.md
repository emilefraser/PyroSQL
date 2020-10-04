# SQL Delta Scripts for Atom

## Installation

Atom comes with great support for snippets out of the box. To install the snippets, do the following:

* Select "File" -> "Snippets..." from the main menu in Atom
* Merge the contents of the file ````snippets.ms-sql.cson```` with the existing snippets file. Appending the contents to the end of the file should be pretty safe.

From this point on, simply set the document language to be SQL and type the name of the snippet you wish to use (e.g. 'createtable-ms') and press tab to insert the code. Placeholders are present to reduce the amount of typing required.

## Notes

* For these snippets to appear, your document must be set to the language "SQL"
* To support other RDBMS systems, the snippets have all been suffixed with "-ms" to indicate they are designed for MS SQL Server