SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_mi_get_collect_script]()
   RETURNS NVARCHAR(MAX)
AS
BEGIN     
   RETURN '[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Data")
[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Diagnostics")
[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Collections")

###############################################################################
# Powershell settings
###############################################################################

# Generate an error if attempt to access a nonexisting variable
Set-PsDebug -Strict

# Global settings for what to do on a error, warning, or verbose call
# Change these settings to change how this script writes output in the agent logs
# Settings also affects how SQL Agent reports success or failure in the script
# Options are:
#      Continue - Continue processing and notify the user 
#             - Agent reaction: step will report success, and
#                           log will include message
#      Inquire - Stop processing and ask the user how it should proceed 
#             - Agent reaction: step fails with "cannot invoke this function"
#                           the Agent PS provider does not implement this
#      SilentlyContinue - Continue processing without notifying the user
#                    - Agent reaction:  will not fail step 
#                                 and will not log any message
#      Stop - Stop processing when an action occurs
#          - Agent reaction: step will fail with message in log
$VerbosePreference = "SilentlyContinue"
$WarningPreference = "Continue"
$ErrorActionPreference = "Stop"

###############################################################################
# Global Variables
###############################################################################

# The following line uses SQL Agent tokens to set the server name
# ESCAPE_SQUOTE(SRVR) with a $ sign in front is a special token to SQL Agent
# When the job is run, SQL Agent will expand the string to the server name
# Use single quotes so that PS considers the string a literal and will not
# try to expand the $ reference and the script will not fail in a test environment
$serverName = ''$(ESCAPE_SQUOTE(SRVR))''

# Currently the best way to tell if the script is running in Agent
# is to check if the console is not the ConsoleHost.  The Powershell
# subsystem for Agent has no console and thus writing to the host directly
# does not show up in the Agent logs.
$isNotConsole = ($host.Name -ne "ConsoleHost")

$connection = $null
$transaction = $null
$isVistaOrXPSp2OrHigher = $null
$sleepTimeoutSeconds = 5
$directoryNameToDeviceId=$null

$cpuStageTableName = "[msdb].[dbo].[sysutility_mi_cpu_stage_internal]"
$cpuStageDataTable = $null
$cpuNumProcessorsColumnName = "num_processors"
$cpuNameColumnName = "cpu_name"
$cpuCaptionColumnName = "cpu_caption"
$cpuFamilyIdColumnName = "cpu_family_id"  
$cpuArchitectureIdColumnName = "cpu_architecture_id"
$cpuMaxClockSpeedColumnName = "cpu_max_clock_speed"
$cpuClockSpeedColumnName = "cpu_clock_speed"
$cpuL2CacheSizeColumnName = "l2_cache_size"
$cpuL3CacheSizeColumnName = "l3_cache_size"
# Start of collection column names
$cpuInstanceProcessorUsageStartTicks = "instance_processor_usage_start_ticks"
$cpuInstanceCollectTimeStartTicks = "instance_collect_time_start_ticks"
$cpuComputerProcessorIdleStartTicks = "computer_processor_idle_start_ticks"
$cpuComputerCollectTimeStartTicks = "computer_collect_time_start_ticks"
# End of collection column names
$cpuInstanceProcessorUsageEndTicks = "instance_processor_usage_end_ticks"
$cpuInstanceCollectTimeEndTicks = "instance_collect_time_end_ticks"
$cpuComputerProcessorIdleEndTicks = "computer_processor_idle_end_ticks"
$cpuComputerCollectTimeEndTicks = "computer_collect_time_end_ticks"


$volumeStageTableName = "[msdb].[dbo].[sysutility_mi_volumes_stage_internal]"
$volumeStageDataTable = $null
$volumeDeviceIdColumnName = "volume_device_id"
$volumeNameColumnName = "volume_name"
$volumeCapacityColumnName = "capacity_mb"
$volumeFreeSpaceColumnName = "free_space_mb"

$smoStageTableName = "[msdb].[dbo].[sysutility_mi_smo_stage_internal]"
$smoStageDataTable = $null
$smoTypeColumnName = "object_type"
$smoUrnColumnName = "urn"
$smoPropertyNameColumnName = "property_name"
$smoPropertyValueColumnName = "property_value"

###############################################################################
# Functions that help with handling output to SQL Agent
#
# Sql Agent PS provider does not write output to the log from
# the warnings, errors, and verbose Write cmdlets.  The following
# functions wrap these cmdlets for execution as an agent job step.
###############################################################################

# This function is a helper function throws an exception if the passed in object 
# is null or empty.  The intent is to mimic the PowerShell version 2.0 parameter 
# validation function with the same name. The paramter validation is available 
# in 2.0 or higher, but this script can run in 1.0 or 2.0 runtime environment.
function ValidateNotNullOrEmpty($object)
{
    if(($object -eq $null) -or ($object -eq ""))
    {
        throw "The argument is null or empty."
    }
}

# This function helps control control flow for the agent step context
# When running within agent, there are different semantics for writing
# errors, warnings, and messages.  In addition, when running inside an
# agent step, the script will automatically collect and stage data.
# However, if the script is loaded in a PS environment outside of 
# agent, the script will not automatically start to collect and stage data
#
# Returns True if the script is run inside an agent step
#         False if the script is run outside an agent step 
function Get-IsAgentStep
{
   $global:isNotConsole
}

function Write-AgentLog([String] $prefix, [String] $printString, [String] $preference)
{
   if((Get-IsAgentStep) -and ($preference -ne "SilentlyContinue"))
   {
      [Console]::Error.WriteLine($prefix + $printString)
   }
}

function Get-PrintString ($object)
{
   ValidateNotNullOrEmpty $object
   
   $date = Get-Date -DisplayHint Time
   $printString = $date.ToString() + " : " +  $object.ToString()
   $printString
}

function Write-ScriptVerbose ($object)
{
   $printString = Get-PrintString $object
   
   Write-AgentLog "VERBOSE : " $printString $VerbosePreference 
   Write-Verbose $printString
}


function Write-ScriptWarning ($object)
{
   $printString = Get-PrintString $object
   
   Write-AgentLog "WARNING : " $printString $WarningPreference 
   Write-Warning $printString
}

function Write-ScriptError ($object)
{
   $printString = Get-PrintString $object
   
   Write-AgentLog "ERROR : " $printString $ErrorActionPreference 
   Write-Error $printString   
}

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $errorString = $ErrorRecord | Format-List * -Force  | Out-String
   Write-ScriptWarning $errorString
   $errorString = $ErrorRecord.InvocationInfo | Format-List * | Out-String
   Write-ScriptWarning $errorString
   $Exception = $ErrorRecord.Exception
   
   # Print the entire stack of exceptions
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   Write-ScriptWarning ("$i" * 80)
       $errorString = $Exception | Format-List * -Force  | Out-String
      Write-ScriptWarning $errorString
   }
}


###############################################################################
# Connection Functions help to send queries to and manage the connection 
# to the server .
###############################################################################
function Get-Connection
{
   if($global:serverName.Contains(''ESCAPE_SQUOTE(SRVR)''))
   {
      throw "The global variable serverName has not been set."
   }
   if($global:connection -eq $null)
   {
      Write-ScriptVerbose "Opening connection to $global:serverName"
      $connString="Application Name=SQL Server Utility Managed Instance;Server=$global:serverName;Database=msdb;Trusted_Connection=True;"
      
      $global:connection = New-Object System.Data.SqlClient.SqlConnection
      $global:connection.ConnectionString = $connString
      [Void]$global:connection.Open()
      Write-ScriptVerbose "Opened connection with connection string:`n $connString"
   }
   $global:connection
}

function Remove-Connection
{
   if($global:connection -ne $null)
   {
      $dataSource=$global:connection.DataSource
      Write-ScriptVerbose "Closing and disposing connection to $dataSource"
      [Void]$global:connection.Close()
      [Void]$global:connection.Dispose()
      Write-ScriptVerbose "Connection is closed and disposed"
   }
   $global:connection = $null
}

function Invoke-BeginTransaction([string] $tranName)
{
   Write-ScriptVerbose "Opening transaction"
   $sqlConnection = Get-Connection
   $global:transaction = $sqlConnection.BeginTransaction($tranName)
}

function Invoke-CommitTransaction
{
   if($global:transaction -ne $null)
   {
      Write-ScriptVerbose "Committing transaction"
      $global:transaction.Commit()
      $global:transaction.Dispose()
      $global:transaction = $null
   }
}

function Invoke-RollbackTransaction
{
   if($global:transaction -ne $null)
   {
      Write-ScriptVerbose "Rolling back transaction"
      $global:transaction.Rollback() 
      $global:transaction.Dispose()
      $global:transaction = $null
   }
}

function Invoke-SubmitSqlCommandNonQuery([string] $query)
{
   ValidateNotNullOrEmpty $query
      
   Write-ScriptVerbose "Submitting as NonQuery : $query"
   $TsqlCommand = New-Object System.Data.SqlClient.SqlCommand;
   $TsqlCommand.CommandText = $query
   $TsqlCommand.CommandType = "Text";
   $TsqlCommand.Transaction = $global:transaction
   
   $TsqlCommand.Connection = Get-Connection
   $TsqlCommand.CommandTimeout = 0
   [Void] $TsqlCommand.ExecuteNonQuery()
}

function Get-SqlDataTable([string] $query)
{
   ValidateNotNullOrEmpty $query
   
   Write-ScriptVerbose "Requesting data table for : $query"
   $sqlConnection = Get-Connection
    $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($query, $sqlConnection)
    $dataTable = New-Object System.Data.DataTable
    $rowsFilled = $dataAdapter.Fill($dataTable)
   Write-ScriptVerbose "Query added $rowsFilled rows to the data table"
    # return the data table.  We need to wrap the variable because PS will
   # return data rows otherwise.
   return @(,($dataTable))
} 

function Invoke-BulkCopyCommand([System.Data.DataTable] $dataTableData)
{
   ValidateNotNullOrEmpty $dataTableData
   
   $opt = [System.Data.SqlClient.SqlBulkCopyOptions] 

   # Obtain a TableLock
   # But do not (use) Default (options), KeepIdentity, CheckConstraints, KeepNulls
   #  FireTriggers,  UseInternalTransaction
   $bulkOptions = $opt::none -bxor ("TableLock" -as $opt) 

   $tabName=$dataTableData.TableName
   Write-ScriptVerbose "Bulk copying data table : $tabName"
   $sqlConnection = Get-Connection
   $bulkCopy = new-object Data.SqlClient.SqlBulkCopy $sqlConnection, $bulkOptions,  $global:transaction
   $bulkCopy.DestinationTableName = $dataTableData.TableName
   
   #Map the columns so that the computed columns are skipped in the upload
   foreach($col in $dataTableData.Columns)
   {
      [Void] $bulkCopy.ColumnMappings.Add($col.ColumnName, 
                                 $col.ColumnName)
   }
   [Void] $bulkCopy.WriteToServer($dataTableData)
   
}

###############################################################################
# Short Helper Functions 
###############################################################################

function Get-DefaultIfNull($object, $default)
{
    if($object -eq $null) 
    {
        $default
    } 
    else
    {
        $object
    }
}

function Get-StringDefaultIfNull([String] $object)
{
    Get-DefaultIfNull $object ""
}

function Get-NumericDefaultIfNull($object)
{
    Get-DefaultIfNull $object 0
}

function Get-ProcessId
{
   $result = Get-SqlDataTable "SELECT SERVERPROPERTY(''ProcessID'') AS ProcessId"  | %{ $_.Rows }
   $result.ProcessId
}

function Get-IsWmiVolumeQueryAvailable
{
   if($global:isVistaOrXPSp2OrHigher -eq $null)
   {
      $osVersion = [System.Environment]::OsVersion.Version
      $global:isVistaOrXPSp2OrHigher = ($osVersion.Major -ge 6 -or ($osVersion.Major -ge 5 -and $osVersion.Minor -ge 2))
   }
   Write-ScriptVerbose "This computer is Vista or XP Sp2 or higher value is $global:isVistaOrXPSp2OrHigher"
   $global:isVistaOrXPSp2OrHigher
}

# Trims the volume name to <drive_letter>: format. 
# Reason: Data collection using WMI on different OS returns diffrent volume formats
# E.g. Win32_LogicalDisk on WIN2K3 returns c: and Win32_Volume on WIN2K8 returns c:\

function Get-FormattedVolumeName([String] $volumeName)
{
   [String] $volumeName = Get-StringDefaultIfNull $volumeName
   
   Write-ScriptVerbose "Formatting volume name $volumeName"
   if($volumeName.EndsWith("\"))
   {
      $volumeName = $volumeName.SubString(0,$volumeName.Length - 1)
   }
   
   Write-ScriptVerbose "Formatted volume name to $volumeName"
   $volumeName
}

function Get-MountPointDictionary()
{
	if($global:directoryNameToDeviceId -eq $null)
	{
		$global:directoryNameToDeviceId=@{}
		(Get-Wmiobject Win32_MountPoint) | 
		%{ $directory=$_.Directory.Replace("Win32_Directory.Name=", "").Replace("`"", "").Replace("\\", "\")
		   $deviceId=$_.Volume.Replace("Win32_Volume.DeviceID=`"", "").Replace("`"", "").Replace("\\", "\")
		   $global:directoryNameToDeviceId[$directory]=$deviceId
		}
	}
	return $global:directoryNameToDeviceId
}

# The following function returns a directory name that maps to a volume device
# based on longest match.  It is not exact because a file can have a long
# convoluted path that pass through many mount point references
# However, it will find the most common use case for mount points
function Get-MountPointName([String] $fileName)
{
    [String] $fileName = Get-StringDefaultIfNull $fileName

    $longestMatch = ""
    $dict = Get-MountPointDictionary
    foreach($directory in $dict.Keys)
    {
        if($fileName.StartsWith($directory, [System.StringComparison]::OrdinalIgnoreCase))
        {
            if($directory.Length -gt $longestMatch.Length)
            {
                $longestMatch = $directory
            }
        }
    }
    return $longestMatch
}


function Get-DeviceIdFromMountPointName([String] $mountPointDirectory)
{
    [String] $mountPointDirectory = Get-StringDefaultIfNull $mountPointDirectory

    $dict = Get-MountPointDictionary
    
    $dict[$mountPointDirectory]
} 

function Get-MegabytesFromBytes ([Uint64] $bytes)
{
   [Uint64] $bytes = Get-NumericDefaultIfNull $bytes
      
   Write-ScriptVerbose "Converting $bytes bytes to megabytes"
   $oneMB = 1048576
   [UInt64] ($bytes / $oneMB)  # No fractional MBs
}

function Get-ShouldCollectCpu
{   
   if( ($global:cpuStageDataTable -eq $null) -or ($global:cpuStageDataTable.Rows.Count -eq 0))
   {
      Write-ScriptVerbose "The cpu staging table is null or empty.  Get-ShouldCollectCpu returning true"
      # return True and exit early
      return $true
   }
   else
   {
      $dataRow = $global:cpuStageDataTable.Rows[0]
      
      # return the value of the disjunction
      $dataRow[$cpuInstanceProcessorUsageStartTicks] -eq 0 -or
         $dataRow[$cpuInstanceCollectTimeStartTicks] -eq 0 -or
         $dataRow[$cpuComputerProcessorIdleStartTicks] -eq 0 -or
         $dataRow[$cpuComputerCollectTimeStartTicks] -eq 0
   }
}

###############################################################################
# Staging Functions that construct DataTables based on the different types of 
# data collection
###############################################################################
function Add-StageCpuRow
{
   param ([Int32] $numProcessors, [String] $cpuName, [String] $cpuCaption, [UInt16] $cpuFamily, 
      [UInt16] $architecture, [UInt32] $cpuMaxClockSpeed, [UInt32] $clockSpeed, 
      [UInt32] $l2CacheSize, [UInt32] $l3CacheSize, 
      [UInt64] $instanceProcessorUsage, [Int64] $instanceCollectTime, 
      [UInt64] $computerIdleTime, [UInt64] $computerCollectTime)

   begin
   {
      # This function update the Cpu table in-place by
      # first querying the server for the previous collection
      # information
      if($global:cpuStageDataTable -eq $null)
      {
         $query = "SELECT  
                  $cpuNumProcessorsColumnName,
                  $cpuNameColumnName,
                  $cpuCaptionColumnName,
                  $cpuFamilyIdColumnName,
                  $cpuArchitectureIdColumnName,
                  $cpuMaxClockSpeedColumnName,
                  $cpuClockSpeedColumnName,
                  $cpuL2CacheSizeColumnName,
                  $cpuL3CacheSizeColumnName,
                  $cpuInstanceProcessorUsageStartTicks,
                  $cpuInstanceCollectTimeStartTicks,
                  $cpuComputerProcessorIdleStartTicks,
                  $cpuComputerCollectTimeStartTicks,
                  $cpuInstanceProcessorUsageEndTicks,
                  $cpuInstanceCollectTimeEndTicks,
                  $cpuComputerProcessorIdleEndTicks,
                  $cpuComputerCollectTimeEndTicks
               FROM $global:cpuStageTableName"
         $global:cpuStageDataTable = Get-SqlDataTable $query
                  
         # If the data table is null, then there is no
         # data on the server and the table needs to be initialized
         if($global:cpuStageDataTable -eq $null)
         {
            Write-ScriptVerbose "Database returned no rows for cpu table. Creating table definition"
            $global:cpuStageDataTable = New-Object System.Data.DataTable ($global:cpuStageTableName)
            
            ($cpuNumProcessorsColumnName, [UInt16]), 
            ($cpuNameColumnName,[string]), 
            ($cpuCaptionColumnName,[string]), 
            ($cpuFamilyIdColumnName, [UInt16]), 
            ($cpuArchitectureIdColumnName, [UInt16]), 
            ($cpuMaxClockSpeedColumnName, [UInt32]), 
            ($cpuClockSpeedColumnName, [UInt32]), 
            ($cpuL2CacheSizeColumnName, [UInt32]), 
            ($cpuL3CacheSizeColumnName, [UInt32]), 
            ($cpuInstanceProcessorUsageStartTicks, [UInt64]), 
            ($cpuInstanceCollectTimeStartTicks, [Int64]), 
            ($cpuComputerProcessorIdleStartTicks, [UInt64]), 
            ($cpuComputerCollectTimeStartTicks, [UInt64]), 
            ($cpuInstanceProcessorUsageEndTicks, [UInt64]), 
            ($cpuInstanceCollectTimeEndTicks, [Int64]),
            ($cpuComputerProcessorIdleEndTicks, [UInt64]), 
            ($cpuComputerCollectTimeEndTicks, [UInt64]) | 
            foreach { ,
               $column =  new-object Data.DataColumn ($_)
               $global:cpuStageDataTable.Columns.Add($column) 
            }
         }
         $global:cpuStageDataTable.TableName = $global:cpuStageTableName
      }
      
      
      # If there is one row in the table, it is the data that the query returned
      # update the start values to be the old end values
      if ($global:cpuStageDataTable.Rows.Count -eq 1)
      {
         Write-ScriptVerbose "Stage table contains one row. Swapping end to start values."
         $dataRow = [System.Data.DataRow] $global:cpuStageDataTable.Rows[0]
   
         # The previous end values become the start values
         $dataRow[$cpuInstanceProcessorUsageStartTicks] = $dataRow[$cpuInstanceProcessorUsageEndTicks]
         $dataRow[$cpuInstanceCollectTimeStartTicks] = $dataRow[$cpuInstanceCollectTimeEndTicks]
         $dataRow[$cpuComputerProcessorIdleStartTicks] = $dataRow[$cpuComputerProcessorIdleEndTicks]
         $dataRow[$cpuComputerCollectTimeStartTicks] = $dataRow[$cpuComputerCollectTimeEndTicks]
      } 
      else
      {
         # There were no rows in the table or too many rows
         # Either way, the data needs to be cleared and updated
         # with the new information
         $rowCount = $global:cpuStageDataTable.Rows.Count
         Write-ScriptVerbose "Number of rows in data table is $rowCount"   
         
         Write-ScriptVerbose "Clearing stage table and marking start values with 0"
         [Void] $global:cpuStageDataTable.Clear()
         $dataRow = [System.Data.DataRow] $global:cpuStageDataTable.NewRow()
         $global:cpuStageDataTable.Rows.Add($dataRow)
         
         # There are no start values
         $dataRow[$cpuInstanceProcessorUsageStartTicks] = 0
         $dataRow[$cpuInstanceCollectTimeStartTicks] = 0
         $dataRow[$cpuComputerProcessorIdleStartTicks] = 0
         $dataRow[$cpuComputerCollectTimeStartTicks] = 0
      }
   }
   
   process
   {
      # Powershell 2.0 does not default typed parameters that are $null
      # So, the function has to set the defaults for the null parameters
      [Int32] $numProcessors = Get-NumericDefaultIfNull $numProcessors
      [String] $cpuName = Get-StringDefaultIfNull $cpuName
      [String] $cpuCaption = Get-StringDefaultIfNull $cpuCaption
      [UInt16] $cpuFamily = Get-NumericDefaultIfNull $cpuFamily
      [UInt16] $architecture = Get-NumericDefaultIfNull $architecture
      [UInt32] $cpuMaxClockSpeed = Get-NumericDefaultIfNull $cpuMaxClockSpeed
      [UInt32] $clockSpeed = Get-NumericDefaultIfNull $clockSpeed
      [UInt32] $l2CacheSize = Get-NumericDefaultIfNull $l2CacheSize
      [UInt32] $l3CacheSize = Get-NumericDefaultIfNull $l3CacheSize
      [UInt64] $instanceProcessorUsage = Get-NumericDefaultIfNull $instanceProcessorUsage
      [Int64] $instanceCollectTime = Get-NumericDefaultIfNull $instanceCollectTime
      [UInt64] $computerIdleTime = Get-NumericDefaultIfNull $computerIdleTime
      [UInt64] $computerCollectTime = Get-NumericDefaultIfNull $computerCollectTime
      
   
      # instanceCollectTime comes in as an signed int, make sure it is not neg
      if($instanceCollectTime -lt 0)
      {
         $instanceCollectTime = 0
      }
      
      # numProcessors comes in as an signed int, make sure it is not neg
      if($numProcessors -lt 0)
      {
         $numProcessors = 0
      }
   
      # Add the collected information
      Write-ScriptVerbose "Adding collected information to data table"
      $dataRow[$cpuNumProcessorsColumnName] = $numProcessors
      $dataRow[$cpuNameColumnName] = $cpuName
      $dataRow[$cpuCaptionColumnName] = $cpuCaption
      $dataRow[$cpuFamilyIdColumnName] = $cpuFamily
      $dataRow[$cpuArchitectureIdColumnName] = $architecture
      $dataRow[$cpuMaxClockSpeedColumnName] = $cpuMaxClockSpeed
      $dataRow[$cpuClockSpeedColumnName] = $clockSpeed
      $dataRow[$cpuL2CacheSizeColumnName] = $l2CacheSize
      $dataRow[$cpuL3CacheSizeColumnName] = $l3CacheSize
      $dataRow[$cpuInstanceProcessorUsageEndTicks] = $instanceProcessorUsage
      $dataRow[$cpuInstanceCollectTimeEndTicks] = $instanceCollectTime
      $dataRow[$cpuComputerProcessorIdleEndTicks] = $computerIdleTime
      $dataRow[$cpuComputerCollectTimeEndTicks] = $computerCollectTime
   }
}



function Add-StageVolumeRow
{ 
   param ([String]$deviceId,
         [String] $volumeNameRaw, 
         [UInt64] $capacityBytes, 
         [UInt64] $freeSpaceBytes)
   begin
   {
      # Initialize the stage table
      if($global:volumeStageDataTable -eq $null)
      {   
         Write-ScriptVerbose "Volume data table is null, creating table definition."
         $global:volumeStageDataTable = New-Object System.Data.DataTable ($global:volumeStageTableName)
            
         ($global:volumeDeviceIdColumnName, [String]), 
         ($global:volumeNameColumnName, [String]), 
         ($global:volumeCapacityColumnName, [UInt64]), 
         ($global:volumeFreeSpaceColumnName, [UInt64])| 
         foreach { ,
            $column =  new-object Data.DataColumn ($_)
            $global:volumeStageDataTable.Columns.Add($column) 
         }
      }
   }
   process
   {
      [String] $deviceId = Get-StringDefaultIfNull $deviceId
      [String] $formattedName = Get-FormattedVolumeName $volumeNameRaw
      [UInt64] $freeSpaceMB = Get-MegabytesFromBytes $freeSpaceBytes
      [UInt64] $capacityMB = Get-MegabytesFromBytes $capacityBytes
      
      if ( ($formattedName -eq "") -or ($deviceId -eq ""))
      {
         Write-ScriptWarning "DeviceId is empty string, or volume name formatting results in empty string.  Skipping this row."
         Write-ScriptWarning "Device Id = $deviceId. Volume name raw = $volumeNameRaw."
         return # return early
      }

      Write-ScriptVerbose "Adding collected information to data table"
      $dataRow = [System.Data.DataRow] $global:volumeStageDataTable.NewRow()
      $dataRow[$global:volumeNameColumnName] = $formattedName
      $dataRow[$global:volumeFreeSpaceColumnName] = $freeSpaceMB
      $dataRow[$global:volumeCapacityColumnName] = $capacityMB
      $dataRow[$global:volumeDeviceIdColumnName] = $deviceId
      Write-ScriptVerbose "Adding row to table"
      
      [Void] $global:volumeStageDataTable.Rows.Add($dataRow)
   }
}


function Add-StageSmoRow
{
   param ([Int32] $type, [String] $objUrn, [String] $propertyName, [object] $value)
   begin
   {      
      # Initialize the stage table
      if($global:smoStageDataTable -eq $null)
      {   
         Write-ScriptVerbose "Smo data table is null, creating table definition."
         $global:smoStageDataTable = New-Object System.Data.DataTable ($global:smoStageTableName)
         
         ($global:smoTypeColumnName, [Int32]), 
         ($global:smoUrnColumnName, [String]), 
         ($global:smoPropertyNameColumnName, [String]), 
         ($global:smoPropertyValueColumnName, [Object]) | 
         foreach { ,
            $column =  new-object Data.DataColumn ($_)
            $global:smoStageDataTable.Columns.Add($column) 
         }   
      }
   }
   process
   {  
      # if the type, propertyName, or Urn is null, something is wrong, throw an exception
      ValidateNotNullOrEmpty $type          
      ValidateNotNUllOrEmpty $propertyName
      ValidateNotNUllOrEmpty $objUrn
      
      # value can be null sometimes, which is fine.  Just throw the row out.
      if ( $value -eq $null )
      {
         Write-ScriptWarning "The value for property $propertyName is null. This property will not be added."
         Write-ScriptWarning "(objUrn = $objUrn)) (type = $type)) (propertyName = $propertyName)) (value = $value))"
         return # return early
      }
      
      Write-ScriptVerbose "Adding collected information for $propertyName to data table"
      $dataRow = [System.Data.DataRow] $global:smoStageDataTable.NewRow()
      $dataRow[$global:smoTypeColumnName] = $type
      $dataRow[$global:smoUrnColumnName] = $objUrn
      $dataRow[$global:smoPropertyNameColumnName] = $propertyName
      $dataRow[$global:smoPropertyValueColumnName] = $value
      
      $global:smoStageDataTable.Rows.Add($dataRow)
      
   }
}
   

###############################################################################
# Collection functions
###############################################################################
function Collect-CpuData
{

   &{ # PS Try
      # Get the Instance-level Performance Data.  An instance is identified 
      # by its process-id
      $processId = Get-ProcessId;
      
      Write-ScriptVerbose "Get WMI percent cpu time for process id = $processId"
      # Get the total processor time from the wmi object
      # PercentProcessorTime is bad property name, it is actually counting the 
      # total number of ticks (100NS based)
      # the instance has spent on processors.
      (Get-WmiObject Win32_PerfRawData_PerfProc_Process -filter "IDProcess = ''$processId''") | 
      %{ $instanceProcessorUsage = $_.PercentProcessorTime };
      
      Write-ScriptVerbose "Get current time for collection time"
      # Find the current number of ticks
      $instanceCollectTime = [DateTime]::UtcNow.Ticks
      
      Write-ScriptVerbose "Get WMI machine cpu time and time stamp"
      # Get the Machine-level Performance Data
      (Get-WmiObject Win32_PerfRawData_PerfOS_Processor -filter "Name = ''_Total''") |
      %{ $computerIdleTime = $_.PercentProcessorTime; 
      $computerCollectTime = $_.TimeStamp_Sys100NS };
      
      Write-ScriptVerbose "Get WMI cpu details"
      # Get the processor details
      (Get-WmiObject Win32_Processor) | 
      %{$cpuName = $_.Name;
      $cpuCaption = $_.Caption;
      $cpuFamily = $_.Family; 
      $architecture = $_.Architecture; 
      $cpuMaxClockSpeed = $_.MaxClockSpeed;
      $clockSpeed = $_.CurrentClockSpeed; 
      $l2CacheSize = $_.L2CacheSize; 
      $l3CacheSize = $_.L3CacheSize };
      
      [Int32] $numProcessors = [System.Environment]::ProcessorCount
      
      Write-ScriptVerbose "Add row to cpu information"
      Add-StageCpuRow   $numProcessors $cpuName $cpuCaption $cpuFamily $architecture $cpuMaxClockSpeed $clockSpeed $l2CacheSize $l3CacheSize $instanceProcessorUsage $instanceCollectTime $computerIdleTime $computerCollectTime
      
      $global:cpuStageDataTable
   }
   # PS Catch
   trap [Exception]
   {
      Resolve-Error
      Write-ScriptError "Caught exception while collecting cpu properties.  A WMI query might have failed."
   }   
   
}

function Collect-VolumeData
{
   &{ # PS Try
      if( Get-IsWmiVolumeQueryAvailable )
      {
         # A null DriveLetter indicates that the volume is a mount point
         # Casting DriveLetter to [Boolean] results in False if it is null 
         Write-ScriptVerbose "Collecting volume information using Win32_Volume"
         (Get-Wmiobject Win32_Volume -filter "DriveType = 3") | 
         %{ Add-StageVolumeRow $_.DeviceId $_.Name $_.Capacity $_.FreeSpace }
      }
      else
      {
         # logical disk only collects disk information, not mount point information
         # hence passing in false as is_mount_point parameter
         Write-ScriptVerbose "Collecting volume information using Win32_LogicalDisk"
         (Get-Wmiobject Win32_LogicalDisk -filter "DriveType = 3") | 
         %{ Add-StageVolumeRow $_.DeviceId $_.Name $_.Size $_.FreeSpace }
      }
      
      $global:volumeStageDataTable
   }
   # PS Catch
   trap [Exception]
   {
      Resolve-Error
      Write-ScriptError "Caught exception while collecting volume properties.  A WMI query might have failed."
   }   
}

function Collect-SmoData
{
   
   &{ # PS try
      $sqlConnection = Get-Connection
      $serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection $sqlConnection
      $server = New-Object Microsoft.SqlServer.Management.Smo.Server($serverConnection);
      
      # remove configurations from this table
      $objectsQuery = "SELECT object_type, sfc_query 
               FROM [msdb].[dbo].[sysutility_mi_smo_objects_to_collect_internal] AS sfc_queries";
      
      $sfcQueries = Get-SqlDataTable $objectsQuery | %{ $_.Rows }
      
      foreach ($sfcQueryRow in $sfcQueries)
      {
         [Int32] $object_type = $sfcQueryRow.object_type;
         $sfcQueryString = $sfcQueryRow.sfc_query.ToString();
   
         Write-ScriptVerbose "Retrieving list of properties to collect"
         $propertiesQuery = "SELECT property_name 
                        FROM [msdb].[dbo].[sysutility_mi_smo_properties_to_collect_internal] 
                        WHERE object_type ="+ $object_type.ToString();
         $properties = Get-SqlDataTable $propertiesQuery | %{ $_.Rows } | foreach { $_.property_name };
         
         Write-ScriptVerbose "Collecting smo information for sfc query $sfcQueryString"
         $oq = New-Object Microsoft.SqlServer.Management.Sdk.Sfc.SfcObjectQuery($server);
         $exp = New-Object Microsoft.SqlServer.Management.Sdk.Sfc.SfcQueryExpression($sfcQueryString);
         
         &{ # PS try
         
            # The following call is not itempotent.  The code does not run the same
            # in debug mode. If you are running in debug mode, any value display
            # invalidates the foreach statement.
            $en = $oq.ExecuteIterator($exp, $null, $null);   
            
            foreach($obj in $en)
            {
               $objUrn = $obj.Urn.ToString();
               Write-ScriptVerbose "Collecting smo information for urn $objUrn"
               
               # For each property get the value and insert it into the smo stage data table
               # the statment $obj.$_ retrieves the propety value from the object
               # going through the PS provider.  If the property is not found or throws an
               # exception from the SMO side, the PS provider wraps the property and returns
               # an empty value.
               $properties | 
               %{ 
                  if ($_ -eq "ProcessorUsage")
                  {
                      # for ProcessorUsage, we are in fact collecting the
                      # the data by ourselves in our own staging table.
                      # and we do not want to call SMO as this property
                      # may not exist on downlevel server.
                      # so here, we put a dummy value and later during upload
                      # we replace it with our real value.
                      # Note that we a similar situation for VolumeFreeSpace
                      # but the solution is different. For VolumeFreeSpace property
                      # it is not put in the sysutility_mi_smo_properties_to_collect_internal
                      # and we collect through other means and then do a join on the UCP
                      # side, versus for ProcessorUsage, we put the property in the list
                      # and during MI collection, we replace it with our own value.
                      # The difference is inconsistent and we should change them to behave
                      # the same in future releases.
                      Add-StageSmoRow $object_type $objUrn $_ [object]0
                  }
                  else
                  {
                      Add-StageSmoRow $object_type $objUrn $_ $obj.$_ 
                  }
                  
                  # if this property is FileName, we append volume/mount point info.
                  if($_ -eq "FileName")
                  {
                     Write-ScriptVerbose "Property is FileName, getting volume information"
                     [String] $mountPointName = Get-MountPointName $obj.FileName
                     Add-StageSmoRow $object_type $objUrn "mount_point_name" $mountPointName 
                     
                     [String] $deviceId = Get-DeviceIdFromMountPointName $mountPointName
                     Add-StageSmoRow $object_type $objUrn "volume_device_id" $deviceId
                  }
               }
               
               $psPath = Convert-UrnToPath $objUrn
               ("powershell_path", $psPath),
               ("parent_name", $obj.Parent.Name),              # If no Parent exists, Ps will return null
               ("grandparent_name", $obj.Parent.Parent.Name) | # If no Parent.Parent exists, Ps will return null
                  %{ ,
                     $propertyName = $_[0]                     
                     [String] $value = $_[1]    # Cast to string results in $null values becoming ""
                     if($value -ne "")
                     {
                        Add-StageSmoRow $object_type $objUrn $propertyName $value
                     }
                  }  
            }
         } # PS catch exception
         trap [Exception]
         {
            Resolve-Error
            Write-ScriptError "Caught exception while collecting smo properties."
         }   
      }
      $global:smoStageDataTable
   } # PS catch exception
   trap [Exception]
   {
      Resolve-Error
          Write-ScriptError "Caught exception while collecting smo properties."
   }   
}

###############################################################################
# Functions that mange the server tables by clearing and loading collected data 
###############################################################################
function Clear-AllStagedData
{
   # TRUNCATE TABLE removes all rows from a table without logging the 
   # individual row deletes.

   $cpuClearQuery = "TRUNCATE TABLE $global:cpuStageTableName; "
   $volumeClearQuery = "TRUNCATE TABLE $global:volumeStageTableName; "
   $smoClearQuery = "TRUNCATE TABLE $global:smoStageTableName; "
   
   Invoke-SubmitSqlCommandNonQuery "$cpuClearQuery $volumeClearQuery $smoClearQuery"
}

function Collect-AllStagedData
{

   Collect-CpuData | Out-Null
      
   # Should we collect cpu data again?
   # This will happen if the script is
   # run when there is no data yet in
   # the cpu staging table.
   if(Get-ShouldCollectCpu)
   {
      #Wait for some time to pass
      Write-ScriptVerbose "Waiting $sleepTimeoutSeconds seconds to collect cpu data."
      Start-Sleep -Seconds $sleepTimeoutSeconds
      #Collect the data again
      Collect-CpuData | Out-Null
   }
   
   Collect-SmoData | Out-Null
   Collect-VolumeData | Out-Null
}

function Save-AllStagedData
{
   Invoke-BulkCopyCommand $global:cpuStageDataTable
   Invoke-BulkCopyCommand $global:volumeStageDataTable
   Invoke-BulkCopyCommand $global:smoStageDataTable
}

function Invoke-StageData
{

   &{ # Try 
      
      Collect-AllStagedData
      
      Invoke-BeginTransaction
      
      Clear-AllStagedData
      Save-AllStagedData
      
      Invoke-CommitTransaction
      Remove-Connection
   }
   trap [Exception] # Catch
   {
      Write-ScriptWarning "Error occurred during execution of script."
      Write-ScriptWarning "Transaction will be rolled back."
      
      Resolve-Error
      
      Invoke-RollbackTransaction
      Remove-Connection
      
      # With ErrorActionPreference=Stop the following line will stop the script
      Write-ScriptError "Error.  Transaction was rolled back"
   }
}

if(Get-IsAgentStep)
{
   Invoke-StageData
}'
END

GO
