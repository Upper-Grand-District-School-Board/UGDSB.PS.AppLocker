function Export-ApplockerRulesCSV {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string]$Path,
    [Parameter(Mandatory = $true)][ValidateNotNull()][object[]]$RulesList
  )
  $applockerRulesExport = [System.Collections.Generic.List[PSObject]]::new()
  foreach ($obj in $RulesList) {
    $export = $obj.PSObject.Copy()
    $hashRules = [System.Collections.Generic.List[String]]::new()
    foreach ($hash in $obj.Hash_Exceptions) {
      $hashRules.Add("$($hash.Data):$($hash.SourceFileName):$($hash.SourceFileLength)")
    }
    $export.Hash_Exceptions = $hashRules -join ","
    $export.File_Exceptions = $obj.File_Exceptions -join ","
    $applockerRulesExport.Add($export)
  }
  $applockerRulesExport | Export-CSV -Path $Path -NoTypeInformation
}