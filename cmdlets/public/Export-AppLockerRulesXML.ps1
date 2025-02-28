function Export-AppLockerRulesXML{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string]$Path,
    [Parameter(Mandatory = $true)][ValidateNotNull()][object[]]$RulesList
  )
  if(-not (Test-Path $Path)){
    New-Item -Path $Path -ItemType Directory
  }
  $script:xmlFile =  [System.Collections.Generic.List[String]]@()
  $script:xmlFile.Add("<AppLockerPolicy Version=`"1`">")
  $rule_category = $RulesList.rule_category | Sort-Object -Unique
  foreach($category in $rule_category){
    Get-RulesXML -category $category -RulesList $RulesList
  }
  $script:xmlFile.Add("</AppLockerPolicy>")
  $outfile = Join-Path -Path $Path -ChildPath "AppLocker.xml"
  $script:xmlFile | Out-File -path $outfile
}