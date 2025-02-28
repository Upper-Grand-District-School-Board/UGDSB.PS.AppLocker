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