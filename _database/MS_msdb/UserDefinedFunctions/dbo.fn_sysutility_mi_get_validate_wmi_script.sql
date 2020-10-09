SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_mi_get_validate_wmi_script]()
   RETURNS NVARCHAR(MAX)
AS
BEGIN     
   RETURN 
'# This script verifies that the following WMI objects are queriable
$objectsToValidate = "Win32_MountPoint", 
                "Win32_PerfRawData_PerfProc_Process", 
                "Win32_PerfRawData_PerfOS_Processor",
                "Win32_Processor",
                "Win32_Volume",
                "Win32_LogicalDisk"
                
# The errorHappend variable keeps track of whether any class failed the check
$errorHappened=$false

# The SQL Agent Powershell subsystem does not have an interactive host associated
# with it, thus standard Write-Host and other host-based cmdlets have no place
# to write to.  This knowledge is used to tell if the script is in an Agent
# or if it is running on a standard PowerShell host.
$isNotConsole = ($host.Name -ne "ConsoleHost")
function Get-IsAgentStep
{
   $global:isNotConsole
}

# Writing to the agent logs is easiest to achieve with [Console]::Error.WriteLine
# If the script is in Agent, write through the Console directly.  If the script
# is not in Agent (someone is using it to debug), then just output to the pipeline.
function Write-AgentLog($object)
{
     if(Get-IsAgentStep)
     {
        [Console]::Error.WriteLine($object)
     } 
     else 
     {
        $object
     }
}

# Query the given WMI object and report pass or fail on the object.
function Validate-WmiObject([string] $wmiObject)
{
   process
   {
      Write-AgentLog "#Running Command:"
      Write-AgentLog "Get-WmiObject $wmiObject | Out-Null"
      
      # Use ErrorVariable and ErrorAction SilentlyContinue so that all of the 
      # objects can be tested without stopping the script or having spurrious messages
      # in the Agent logs.  
      Get-WmiObject $wmiObject -ErrorVariable wmiError -ErrorAction SilentlyContinue | Out-Null
      
      # Check the error message and report pass or fail
      if($wmiError)
      {
         $global:errorHappened=$true
         Write-AgentLog "#Command FAILED. Exception : $wmiError"
      }
      else
      {
         Write-AgentLog "#Command PASSED."
      }

   }
}

# Validate all of the Wmi objects.  If any one of them fail, then
# report an error.
function Validate-AllWmiObjects
{
   $objectsToValidate | %{ 
      Validate-WmiObject $_ 
   }
   
   if($global:errorHappened)
   {
      Write-Error -ErrorAction Stop "One or more WMI classes failed the test"
   }
}

# Automatically check the status of the objects if the script is running in Agent
# Otherwise, allow the user to call the Validate functions interactively.
if(Get-IsAgentStep)
{ 
   Validate-AllWmiObjects
}
'
END

GO
