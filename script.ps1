$TenantID = "26f0aa56-6ea4-4ee3-a813-076788c06e60"
$ApplicationID = "3a0842ee-aadd-46ee-bb7a-5f4b165781c6"
$ApplicationSecret = "Mer8Q~wpcKgfYSWdREZ8QY7ulQbnnCTNtpOI0aV-"
$SecurePassword = ConvertTo-SecureString "$ApplicationSecret" -AsPlainText -Force
$AzureCredentials = New-Object System.Management.Automation.PSCredential 
("$ApplicationID", $SecurePassword)
 
Connect-AzAccount -ServicePrincipal -Tenant $TenantID -Credential $AzureCredentials
-Force
 
[int]$month = Get-Date -Format MM
$year = Get-Date -Format yyyy
$startdate = "$year-$month-01"
$enddate = Get-Date -Format yyyy-MM-dd
Remove-Item -Path "D:\home\site\wwwroot\output\ResourceGroup-Wise-Cost.csv" 
-ErrorAction SilentlyContinue -Force -Verbose
$outpath = "D:\home\site\wwwroot\output\ResourceGroup-Wise-Cost.csv"
$monthname = switch($month){
 01 {"Jan"}
 02 {"Feb"}
 03 {"Mar"}
 04 {"Apr"}
 05 {"May"}
 06 {"Jun"}
 07 {"Jul"}
 08 {"Aug"}
 09 {"Sep"}
 10 {"Oct"}
 11 {"Nov"}
 12 {"Dec"}
}
$subsctiptionlist = Get-AzSubscription
 "ResourceGroupName,UsageMonth,SubscriptionName,Cost,Location" | Out-File 
-FilePath $outpath -Encoding utf8
$subsctiptionlist | foreach {
 $subscription = $_.Name
 $tenantid = $_.TenantId
 
 $subselect = Select-AzSubscription -Subscription $subscription -Tenant 
$tenantid
 
 $pretaxcost = $null
 $pretaxcost = Get-AzConsumptionUsageDetail -StartDate $startdate 
-EndDate $enddate
 $rglist = Get-AzResourceGroup
 $rglist | foreach {
 
 $rgname = $_.ResourceGroupName
 $rglocation = $_.Location
 
 $rgcostinfo = $pretaxcost | where {$_.InstanceId -like "*$rgname*"}
 
 
 $costvalue = 0
 $rgcostinfo | foreach {
 
 
 $precostvalue = $null
 $precostvalue = $_.PretaxCost
 $costvalue = $costvalue + $precostvalue 
 
 }
 $cost = $null
 $cost = [math]::Round($costvalue,3)
 "$rgname,$monthname,$subscription,$cost,$rglocation"
 "$rgname,$monthname,$subscription,$cost,$rglocation" | Out-File 
-FilePath $outpath -Append -Encoding utf8
 
 }
}