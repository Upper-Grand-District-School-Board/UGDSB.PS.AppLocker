function Get-RulesXML{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string]$category,
    [Parameter(Mandatory = $true)][ValidateNotNull()][object[]]$RulesList
  )
  $enfrocementMode = "AuditOnly"
  $rules = $RulesList | Where-Object {$_.rule_category -eq $category}
  if($rules.EnforcementMode.Contains("Enabled")){
    $enfrocementMode = "Enabled"
  }
  $xmlFile.Add("  <RuleCollection Type=`"$($category)`" EnforcementMode=`"$($enfrocementMode)`">")
  foreach ($rule in $rules) {
    switch ($rule.type) {
      "FilePublisherRule" {
        Get-FilePublisherRule -rule $rule
      }
      "FilePathRule" {
        Get-FilePathRule -rule $rule
      }
      "FileHashRule" {
        Get-FileHashRule -rule $rule
      }
    }    
  }
  $xmlFile.Add("  </RuleCollection>")  
}