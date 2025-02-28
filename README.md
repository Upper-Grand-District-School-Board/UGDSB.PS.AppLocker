# UGDSB.PS.AppLocker

## ##  THIS IS STILL A WORK IN PROGRESS. THERE ARE FUNCTIONS THAT ARE NOT COMPLETE  \##

## ##  DOCUMENTATION FORTHCOMING. \##

## ##  PWSH 7 \##

This module is designed to be able to import, export and manipulate AppLocker files. Initially you would import a RAW XML file for your policy and then you can export it to a CSV file. You can then make changes to the CSV file for new rules, or seperate files for say a general applocker policy but another tighter scoped policy that has additional rules can be then used to generate that XML. It can also export the individual XML files used for an Intune policy instead of the full AppLocker XML.

## Install Instructions

Currently you would just import the module manually, eventually when feel better about the project will upload it to the PowerShell Gallery

```
$localModule = Join-Path -Path (Get-Item -Path $PSScriptRoot).Parent -ChildPath "Module" -AdditionalChildPath "UGDSB.PS.AppLocker"
Import-Module -Name $localModule -Force
```

## Import XML to convert to CSV
```
$in = Join-Path -Path $PSScriptRoot -ChildPath Applocker.xml
$out = Join-Path -Path $PSScriptRoot -ChildPath Applocker.csv
$rulelist = Import-ApplockerRulesXML -path $in
Export-ApplockerRulesCSV -Path $out -RulesList $rulelist
```

## Take CSV file and convert back to AppLocker XML file
```
$in = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker.csv
$out = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker
$rules = Import-ApplockerRulesCSV -path $in
Export-AppLockerRulesXML -RulesList $rules -Path $out
```

``` Take multiple CSV files and convert to an AppLocker XML file
$in1 = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker.csv
$in2 = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_Additional.csv
$out = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker
$rules = Import-ApplockerRulesCSV -path $in1,$in2
Export-AppLockerRulesXML -RulesList $rules -Path $out
```

## Take CSV file and convert to category split for AppLocker XML files
```
$in = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker.csv
$out = Join-Path -Path $PSScriptRoot -ChildPath Win_Device_OS_AppLocker
$rules = Import-ApplockerRulesCSV -path $in
Export-ApplockerRulesIntuneXML -RulesList $rules -Path $out
```

