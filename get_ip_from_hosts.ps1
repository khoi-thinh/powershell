<# This function take in a list of hostname and return IPs (if hostname exists and can be resolved), otherwise it return Unknown. 
Can import function to profile to make it available as cmdlet
Run the below command and copy the function content into it
notepad $profile 

Function support pipeline input so the usage can be any of the following
Get-IPFromHost hostname
hostname | Get-IPFromHost
Get-Content hostname_list.txt | Get-IPFromHost

#>
function Get-IPFromHost {
    [cmdletbinding()]
    param (
    [Parameter(Mandatory,valuefrompipeline)]
    [string[]]$pc_list
    )

    begin {}

    process {
        foreach ($pc in $pc_list) {
            $props = @{'HostName'=$pc}
            try {
                $result = [System.Net.Dns]::GetHostAddresses($pc)
                $props.add('IP',$result.IPAddressToString)
            } #try
        
            catch {
                $props.add('IP','Unknown')
            } #catch
         New-Object -TypeName PSObject -Property $props
         } #foreach
    } #process

    end {}

} #function
