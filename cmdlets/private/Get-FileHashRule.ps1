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