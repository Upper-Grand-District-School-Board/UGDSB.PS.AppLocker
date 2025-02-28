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