# NAMING 

## File Paths

Standard naming of objects follow this pattern

{{schema}}.{{objectname}}.{{objecttype}}.sql
or
{{database}}.{{schema}}.{{objectname}}.{{objecttype}}.sql
or
{{server}}.{{database}}.{{schema}}.{{objectname}}.{{objecttype}}.sql

WHERE 

{{objecttype}} is:
* Table
* View
* StoredProcedure
* Schema
* Database
* Index
* Synonym
* Constraint
* UserDefinedFunction
* Job

{{objectname}}:
* Now vw_ or other bs prefixes
* follows {{Action Verb}}{{Object Noun}}{{Column Name}}_{{{Extension Part}}}
* Used Camel Case

{{Action Verb}}:
* Create (DDL)
* Insert
* Update
* Delete
* Truncate
* Set
* Append (?)
* Help
* Calculate
* Provision
* Report
* Materialize
* Execute
* Resurse
* Summize
* Determine (1/0)
* Start
* Stop
* Pause
* Cancel
* Audit
* Test
* Parse
* Split
* Combine
* Compare