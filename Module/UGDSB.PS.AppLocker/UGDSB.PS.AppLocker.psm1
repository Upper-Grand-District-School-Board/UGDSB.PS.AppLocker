#Region '.\Public\Export-ApplockerRulesCSV.ps1' 0
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
#EndRegion '.\Public\Export-ApplockerRulesCSV.ps1' 20
#Region '.\Public\Export-ApplockerRulesIntuneXML.ps1' 0
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
#EndRegion '.\Public\Export-ApplockerRulesIntuneXML.ps1' 18
#Region '.\Public\Export-AppLockerRulesXML.ps1' 0
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
#EndRegion '.\Public\Export-AppLockerRulesXML.ps1' 20
#Region '.\Public\Get-AppLockerRuleConditionXML.ps1' 0
function Get-AppLockerRuleConditionXML {
  [CmdletBinding()]
  param(
    [Parameter()][ValidateSet('Appx', 'DLL', 'Exe', 'Msi', 'Script')][string]$rule_category,
    [Parameter()][ValidateSet('Enabled', 'Disabled', 'AuditOnly')][string]$EnforcementMode,
    [Parameter()][string]$Type,
    [Parameter()][object]$rules
  )
  
  foreach ($rule in $rules) {
    $filterRule = $false
    switch ($script:filterlist.Keys) {
      "id" {
        if ($rule.Id -ne $script:filterlist.id) { $filterRule = $true }
      }
      "UserOrGroupSid" {
        if ($rule.UserOrGroupSid -ne $script:filterlist.UserOrGroupSid) { $filterRule = $true }
      }
      "Name" {
        if ($rule.Name -ne $script:filterlist.Name) { $filterRule = $true }
      }
      "Action" {
        if ($rule.Action -ne $script:filterlist.Action) { $filterRule = $true }
      }   
      "PublisherName" {
        if ($rule.conditions.FilePublisherCondition.PublisherName -ne $script:filterlist.PublisherName) { $filterRule = $true }
      }  
      "ProductName" {
        if ($rule.conditions.FilePublisherCondition.ProductName -ne $script:filterlist.ProductName) { $filterRule = $true }
      }    
      "BinaryName" {
        if ($rule.conditions.FilePublisherCondition.BinaryName -ne $script:filterlist.BinaryName) { $filterRule = $true }
      }
      "FilePath" {
        if ($rule.conditions.FilePathCondition.Path -ne $script:filterlist.FilePath) { $filterRule = $true }
      }
      "hash" {
        if ($rule.conditions.FileHashCondition.FileHash.Data -ne $script:filterlist.hash) { $filterRule = $true }
      }
      "SourceFileName" {
        if ($rule.conditions.FileHashCondition.FileHash.SourceFileName -ne $script:filterlist.SourceFileName) { $filterRule = $true }
      }
    }
    if (-not $filterRule) {
      if($rule.Name.contains('"')){
        $rule.Name = ([System.Web.HttpUtility]::HtmlEncode($rule.Name))
      }
      $obj = [PSCustomObject]@{
        rule_category    = $rule_category
        EnforcementMode  = $EnforcementMode
        Type             = $Type
        Id               = $rule.Id
        Name             = $rule.Name
        Description      = $rule.Description
        UserOrGroupSid   = $rule.UserOrGroupSid
        Action           = $rule.Action    
        PublisherName    = $rule.conditions.FilePublisherCondition.PublisherName
        ProductName      = $rule.conditions.FilePublisherCondition.ProductName
        BinaryName       = $rule.conditions.FilePublisherCondition.BinaryName
        LowSection       = $rule.conditions.FilePublisherCondition.BinaryVersionRange.LowSection
        HighSection      = $rule.conditions.FilePublisherCondition.BinaryVersionRange.HighSection    
        Path             = $rule.conditions.FilePathCondition.Path
        File_Exceptions  = $rule.Exceptions.FilePathCondition.Path
        Data             = $rule.conditions.FileHashCondition.FileHash.Data
        SourceFileName   = $rule.conditions.FileHashCondition.FileHash.SourceFileName
        SourceFileLength = $rule.conditions.FileHashCondition.FileHash.SourceFileLength    
        Hash_Exceptions  = $rule.Exceptions.FileHashCondition.Filehash
      }
      $script:applockerRules.Add($obj)      
    }
  }
}
#EndRegion '.\Public\Get-AppLockerRuleConditionXML.ps1' 73
#Region '.\Public\Get-FileHashRule.ps1' 0
function Get-FileHashRule {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][PSCustomObject]$rule
  )
  $script:xmlFile.Add("    <FileHashRule Id=`"$($rule.id)`" Name=`"$($rule.Name)`" Description=`"$($rule.Description)`" UserOrGroupSid=`"$($rule.UserOrGroupSid)`" Action=`"$($rule.Action)`">")
  $script:xmlFile.Add("      <Conditions>")
  $script:xmlFile.add("        <FileHashCondition>")
  $script:xmlFile.add("          <FileHash Type=`"SHA256`" Data=`"$($rule.Data)`" SourceFileName=`"$($rule.SourceFileName)`" SourceFileLength=`"$($rule.SourceFileLength)`" />")
  $script:xmlFile.add("        </FileHashCondition>")
  $script:xmlFile.Add("      </Conditions>")
  $script:xmlFile.Add("    </FileHashRule>")
}
#EndRegion '.\Public\Get-FileHashRule.ps1' 14
#Region '.\Public\Get-FilePathRule.ps1' 0
function Get-FilePathRule {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][PSCustomObject]$rule
  )
  $script:xmlFile.Add("    <FilePathRule Id=`"$($rule.id)`" Name=`"$($rule.Name)`" Description=`"$($rule.Description)`" UserOrGroupSid=`"$($rule.UserOrGroupSid)`" Action=`"$($rule.Action)`">")
  $script:xmlFile.Add("      <Conditions>")
  $script:xmlFile.add("        <FilePathCondition Path=`"$($rule.path)`" />")
  $script:xmlFile.Add("      </Conditions>")
  if ($rule.File_Exceptions -or $rule.Hash_Exceptions) {
    $script:xmlFile.Add("      <Exceptions>")
    if ($rule.File_Exceptions) {
    
      $exceptionList = $rule.File_Exceptions
      foreach ($exception in ($exceptionList -split ",")) {
        $script:xmlFile.Add("        <FilePathCondition Path=`"$($exception.trim())`" />")
      }
    }
    if ($rule.Hash_Exceptions) {
      $exceptionList = $rule.Hash_Exceptions
      foreach ($exception in $rule.Hash_Exceptions) {
        $script:xmlFile.Add("        <FileHashCondition>")
        $script:xmlFile.Add("          <FileHash Type=`"SHA256`" Data=`"$($exception.data)`" SourceFileName=`"$($exception.SourceFileName)`" SourceFileLength=`"$($exception.SourceFileLength)`" />")
        $script:xmlFile.Add("        </FileHashCondition>")
      }
    
    }
    $script:xmlFile.Add("      </Exceptions>")
  }
  $script:xmlFile.Add("    </FilePathRule>")
}
#EndRegion '.\Public\Get-FilePathRule.ps1' 32
#Region '.\Public\Get-FilePublisherRule.ps1' 0
function Get-FilePublisherRule {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][PSCustomObject]$rule
  )
  $script:xmlFile.Add("    <FilePublisherRule Id=`"$($rule.id)`" Name=`"$($rule.Name)`" Description=`"$($rule.description)`" UserOrGroupSid=`"$($rule.UserOrGroupSid)`" Action=`"$($rule.Action)`">")
  $script:xmlFile.Add("      <Conditions>")
  $script:xmlFile.add("        <FilePublisherCondition PublisherName=`"$($rule.PublisherName)`" ProductName=`"$($rule.ProductName)`" BinaryName=`"$($rule.BinaryName)`">")
  $script:xmlFile.add("          <BinaryVersionRange LowSection=`"$($rule.LowSection)`" HighSection=`"$($rule.HighSection)`" />")
  $script:xmlFile.add("        </FilePublisherCondition>")
  $script:xmlFile.Add("      </Conditions>")
  $script:xmlFile.Add("    </FilePublisherRule>")
}
#EndRegion '.\Public\Get-FilePublisherRule.ps1' 14
#Region '.\Public\Get-RulesXML.ps1' 0
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
#EndRegion '.\Public\Get-RulesXML.ps1' 28
#Region '.\Public\Import-AppLockerRulesCSV.ps1' 0
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
#EndRegion '.\Public\Import-AppLockerRulesCSV.ps1' 63
#Region '.\Public\Import-ApplockerRulesXML.ps1' 0
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
#EndRegion '.\Public\Import-ApplockerRulesXML.ps1' 53
