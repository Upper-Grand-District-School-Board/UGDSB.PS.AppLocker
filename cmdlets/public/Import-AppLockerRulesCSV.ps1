function Import-AppLockerRulesCSV {
  [CmdletBinding(DefaultParameterSetName = "General")]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string[]]$Path,
    [Parameter()][ValidateSet('Appx', 'DLL', 'Exe', 'Msi', 'Script')][string]$rule_category,
    [Parameter()][ValidateSet('Enabled', 'Disabled', 'AuditOnly')][string]$EnforcementMode,
    [Parameter()][ValidateSet('FilePublisherRule', 'FilePathRule', 'FileHashRule')][string]$Type,
    [Parameter()][ValidateNotNull()][string]$UserOrGroupSid,
    [Parameter()][ValidateNotNull()][string]$id,
    [Parameter()][ValidateNotNull()][string]$Name,
    [Parameter()][ValidateSet('Allow', 'Block')][string]$Action,
    [Parameter(ParameterSetName = "FilePublisherRule")][ValidateNotNull()][string]$PublisherName,
    [Parameter(ParameterSetName = "FilePublisherRule")][ValidateNotNull()][string]$ProductName,
    [Parameter(ParameterSetName = "FilePublisherRule")][ValidateNotNull()][string]$BinaryName,
    [Parameter(ParameterSetName = "FilePathRule")][ValidateNotNull()][string]$FilePath,
    [Parameter(ParameterSetName = "FileHashRule")][ValidateNotNull()][string]$hash,
    [Parameter(ParameterSetName = "FileHashRule")][ValidateNotNull()][string]$SourceFileName
  )  
  # Import CSV file into PowerShell Object
  $applockerContent = foreach($item in $Path){
    Import-Csv -Path $item
  }
  # If Type is selected, skip any rule type that is not selected.
  $filterList = [System.Collections.Generic.List[String]]::new()
  if ($PSBoundParameters.ContainsKey("rule_category")) { $filterList.Add("`$_.rule_category -eq '$($rule_category)'")} 
  if ($PSBoundParameters.ContainsKey("EnforcementMode")) { $filterList.Add("`$_.EnforcementMode -eq '$($EnforcementMode)'")} 
  if ($PSBoundParameters.ContainsKey("id")) { $filterlist.Add("`$_.id -eq '$($id)'") }
  if ($PSBoundParameters.ContainsKey("UserOrGroupSid")) { $filterlist.Add("`$_.UserOrGroupSid -eq '$($UserOrGroupSid)'") }
  if ($PSBoundParameters.ContainsKey("Name")) { $filterlist.Add("`$_.Name -eq '$($Name)'") }
  if ($PSBoundParameters.ContainsKey("Action")) { $filterlist.Add("`$_.Action -eq '$($Action)'") }
  if ($PSBoundParameters.ContainsKey("PublisherName")) { $filterlist.Add("`$_.PublisherName -eq '$($PublisherName)'") }
  if ($PSBoundParameters.ContainsKey("ProductName")) { $filterlist.Add("`$_.ProductName -eq '$($ProductName)'") }
  if ($PSBoundParameters.ContainsKey("BinaryName")) { $filterlist.Add("`$_.BinaryName -eq '$($BinaryName)'") }
  if ($PSBoundParameters.ContainsKey("FilePath")) { $filterlist.Add("`$_.FilePath -eq '$($FilePath)'") }
  if ($PSBoundParameters.ContainsKey("hash")) { $filterlist.Add("`$_.Data -eq '$($hash)'") }
  if ($PSBoundParameters.ContainsKey("SourceFileName")) { $filterlist.Add("`$_.SourceFileName -eq '$($SourceFileName)'") }  
  if($filterList){
    $filterList = [Scriptblock]::Create($filterList -join " -and ")
    $applockerContent = $applockerContent | Where-Object -FilterScript $filterList
  }
  # Loop through the CSV and make the changes for Array objects that were converted to strings
  foreach ($rules in $applockerContent) {
    if ($rules.File_Exceptions) {
      $rules.File_Exceptions = $rules.File_Exceptions -split ","
    }
    if ($rules.Hash_Exceptions) {
      $hashRules = [System.Collections.Generic.List[PSCustomObject]]::new()
      $split = $rules.Hash_Exceptions -split ","
      foreach ($obj in $split) {
        $parts = $obj -split ":"
        $hashRules.Add([PSCustomObject]@{
            Type             = "SHA256"
            Data             = $parts[0]
            SourceFileName   = $parts[1]
            SourceFileLength = $parts[2]
          })
      }
      $rules.Hash_Exceptions = $hashRules
    }
  }
  return $applockerContent  
}
