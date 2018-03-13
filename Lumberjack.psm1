using module .\New-FunctionFromConstructors\New-FunctionFromConstructors.psm1

#in something: Write-Information $l , then you can do this ridiculousness:
#$b= $( $a =.\foo.ps1 ) 6>&1
#$l.Cannibalize($b)

CLASS Log {
    [String]$Message
    [Object[]]$Objects
    [String[]]$Tags
    [Datetime]$Timestamp
    
    [ConstructorName('MessageObjectsTags')]
    Log ([String]$Message, [Object[]]$Objects, [String[]]$Tags ) {
        $this.Timestamp = Get-Date
        $this.Message = $Message
        $this.Objects = $Objects
        $this.Tags = $Tags 
        }

    [ConstructorName('MessageTags')]
    Log ([String]$Message, [String[]]$Tags ) {
        $this.Timestamp = Get-Date
        $this.Message = $Message
        $this.Tags = $Tags 
        }

    [ConstructorName('Message')]
    Log ([String]$Message  ) {
        $this.Timestamp = Get-Date
        $this.Message = $Message
        }

}<# END CLASS LOG #>


CLASS Lumberjack {
    [System.Collections.ArrayList]$Logs
    [Ref]$Ref

    [ConstructorName('Default')]
    Lumberjack () { $this.Logs = [System.Collections.ArrayList]::NEW() 
        $this.Ref = [Ref]$this}

    AddLog ([Log]$Log) {
        $this.Logs.Add($Log)
    }

    Cannibalize ([Lumberjack]$Lumberjack) {$Lumberjack.Logs | ForEach-Object { $this.AddLog($_) }  }

    [Log[]] FilterByTags ([String[]]$Tags) {
        $set = $this.Logs
        $filters = Foreach ($t in $Tags) { [ScriptBlock]::Create("'$t' -in `$_.Tags") }
        Foreach ($f in $filters) {$set = $set | Where-Object $f }
        Return $set 
        }<# END [Log[]] FilterByTags ([String[]]$Tags) #>

}


FUNCTION Write-Log {
[CMDLETBINDING()]
PARAM(
     [Ref]$Lumberjack
    ,[String]$Message
    )
$Lumberjack.Value.AddLog($(New-Object-Log-Message -Message $Message))
}

FUNCTION New-Object-Lumberjack-Default {
[CmdletBinding(PositionalBinding=$true)]
PARAM()
BEGIN{}
PROCESS{
$([Lumberjack].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'Default'} ).Invoke(@())
}
END{}
}
        


FUNCTION New-Object-Log-MessageObjectsTags {
[CmdletBinding(PositionalBinding=$true)]
PARAM([PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string]$Message,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][System.Object[]]$Objects,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string[]]$Tags)
BEGIN{}
PROCESS{
$([Log].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'MessageObjectsTags'} ).Invoke(@($Message,$Objects,$Tags))
}
END{}
}
New-Alias -Name 'lmot' -Value New-Object-Log-MessageObjectsTags        

FUNCTION New-Object-Log-MessageTags {
[CmdletBinding(PositionalBinding=$true)]
PARAM([PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string]$Message,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string[]]$Tags)
BEGIN{}
PROCESS{
$([Log].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'MessageTags'} ).Invoke(@($Message,$Tags))
}
END{}
}
New-Alias -Name 'lmt' -Value New-Object-Log-MessageTags

FUNCTION New-Object-Log-Message {
[CmdletBinding(PositionalBinding=$true)]
PARAM([PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string]$Message)
BEGIN{}
PROCESS{
$([Log].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'Message'} ).Invoke(@($Message))
}
END{}
}
New-Alias -Name 'lm' -Value New-Object-Log-Message
        
