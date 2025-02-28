function Import-ApplockerRulesXML {
  [CmdletBinding(DefaultParameterSetName = "General")]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNull()][string]$Path,
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
  # Import XML file into PowerShell Object
  [xml]$applockerContent = Get-Content -Path $Path
  # Create a PSObject to return that is filtered to what we would be wanting to look at
  $script:applockerRules = [System.Collections.Generic.List[PSObject]]::new()
  $script:filterlist = @{}
  # Generate Filter
  if ($PSBoundParameters.ContainsKey("id")) { $script:filterlist.Add("id", $id) }
  if ($PSBoundParameters.ContainsKey("UserOrGroupSid")) { $script:filterlist.Add("UserOrGroupSid", $UserOrGroupSid) }
  if ($PSBoundParameters.ContainsKey("Name")) { $script:filterlist.Add("Name", $Name) }
  if ($PSBoundParameters.ContainsKey("Action")) { $script:filterlist.Add("Action", $Action) }
  if ($PSBoundParameters.ContainsKey("PublisherName")) { $script:filterlist.Add("PublisherName", $PublisherName) }
  if ($PSBoundParameters.ContainsKey("ProductName")) { $script:filterlist.Add("ProductName", $ProductName) }
  if ($PSBoundParameters.ContainsKey("BinaryName")) { $script:filterlist.Add("BinaryName", $BinaryName) }
  if ($PSBoundParameters.ContainsKey("FilePath")) { $script:filterlist.Add("FilePath", $FilePath) }
  if ($PSBoundParameters.ContainsKey("hash")) { $script:filterlist.Add("hash", $hash) }
  if ($PSBoundParameters.ContainsKey("SourceFileName")) { $script:filterlist.Add("SourceFileName", $SourceFileName) }
  foreach ($rules in $applockerContent.AppLockerPolicy.RuleCollection) {
    # If Type is selected, skip any rule type that is not selected.
    if ($PSBoundParameters.ContainsKey("rule_category") -and $rules.type -ne $rule_category) { continue }
    # If EnforcementMode is selected, skip any rule type that is not equal.
    if ($PSBoundParameters.ContainsKey("EnforcementMode") -and $rules.EnforcementMode -ne $EnforcementMode) { continue }
    # Get Rules
    if (-not $PSBoundParameters.ContainsKey("Type") -or ($PSBoundParameters.ContainsKey("Type") -and $Type -eq "FilePublisherRule")) {
      Get-AppLockerRuleConditionXML -rule_category $rules.type -EnforcementMode $rules.EnforcementMode -Type "FilePublisherRule" -Rules $rules.FilePublisherRule
    }
    if (-not $PSBoundParameters.ContainsKey("Type") -or ($PSBoundParameters.ContainsKey("Type") -and $Type -eq "FilePathRule")) {
      Get-AppLockerRuleConditionXML -rule_category $rules.type -EnforcementMode $rules.EnforcementMode -Type "FilePathRule" -Rules $rules.FilePathRule
    }
    if (-not $PSBoundParameters.ContainsKey("Type") -or ($PSBoundParameters.ContainsKey("Type") -and $Type -eq "FileHashRule")) {
      Get-AppLockerRuleConditionXML -rule_category $rules.type -EnforcementMode $rules.EnforcementMode -Type "FileHashRule" -Rules $rules.FileHashRule
    }
  }
  return $script:applockerRules
}