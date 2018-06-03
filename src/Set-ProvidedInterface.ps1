PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $ProvidedInterface
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[ValidateNotNullOrEmpty()]
	[string] $Interface
	,
	[ValidateScript( { Test-Path($_); } )]
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $Model
	,
    [switch] $Force = $true
    ,
	[Parameter(Mandatory = $false)]
	[string] $EaInterop = 'Sparx Systems\EA\Interop.EA.dll'
)

<#
{2EA70063-2D70-4670-9F61-5864AF8E485A}

Interface

{C6A724FD-2BE5-47bd-836E-934D5116C00E}

Provided Interface
 #>

BEGIN 
{
	$OutputParameter = $null;

	$EaInteropPathAndFileName = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath $EaInterop;
	Add-Type -Path $EaInteropPathAndFileName;
	$ea = New-Object -ComObject EA.Repository;

	$result = $ea.OpenFile($Model);
}

PROCESS 
{
	$source = $ea.GetElementByGuid([Guid]::Parse($ProvidedInterface).ToString('B'));
	$target = $ea.GetElementByGuid([Guid]::Parse($Interface).ToString('B'));

    if($Force)
    {
        $cMax = $source.Connectors.Count;
        for($c = 0; $c -lt $cMax; $c++)
        {
            $source.Connectors.Delete(0);
            $source.Connectors.Refresh();
        }
    }

    $connector = $source.Connectors.AddNew([string]::Empty, 'Realization');
	$connector.SupplierID = $target.ElementID;

    #$tag = $connector.TaggedValues.AddNew("biz.dfch.EA.SetInterface", '1.0.0');
    #$tag.Update();
    #$connector.TaggedValues.Refresh();

    $result = $connector.Update();
    $source.Connectors.Refresh();

    $source.ClassifierID = $target.ElementID;
    $source.Name = $target.Name;
    $source.Update()
}

END 
{
	$ea.CloseFile();
	$ea.Exit();
}
