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