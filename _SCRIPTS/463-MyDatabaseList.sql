--connect to production
:CONNECT myServer\MyInstance
use payroll --or whatever the database name is
:r $(workpath)$(FileToExecute)
use accounts--or whatever the database name is
:r $(workpath)$(FileToExecute)
use HR--or whatever the database name is
:r $(workpath)$(FileToExecute)
use manufacturing--or whatever the database name is
:r $(workpath)$(FileToExecute)
--connect to test server
:CONNECT myServer\MyInstance
use payroll --or whatever the database name is
:r $(workpath)$(FileToExecute)
use accounts--or whatever the database name is
:r $(workpath)$(FileToExecute)
use HR--or whatever the database name is
:r $(workpath)$(FileToExecute)
use manufacturing--or whatever the database name is
:r $(workpath)$(FileToExecute)
--and so on for all your 200 servers!



