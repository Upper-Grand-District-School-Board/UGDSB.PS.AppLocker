function Export-ApplockerRulesIntuneXML{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string]$Path,
    [Parameter(Mandatory = $true)][ValidateNotNull()][object[]]$RulesList
  )
  if(-not (Test-Path $Path)){
    New-Item -Path $Path -ItemType Directory
  }
  $rule_category = $RulesList.rule_category | Sort-Object -Unique
  foreach($category in $rule_category){
    $script:xmlFile =  [System.Collections.Generic.List[String]]@()
    Get-RulesXML -category $category -RulesList $RulesList
    $outfile = Join-Path -Path $Path -ChildPath "AppLocker_$($category).xml"
    $script:xmlFile | Out-File -path $outfile
  }
}