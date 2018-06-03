PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $Component
	,
	#[Parameter(Mandatory = $true, Position = 1)]
	#[ValidateNotNullOrEmpty()]
	#[string] $Interface
	#,
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

$PSDefaultParameterValues.'Set-NestedComponent.ps1:Model' = 'C:\myModel.EAP'
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
    trap { Log-Exception $_; break; }
 
	$source = $ea.GetElementByGuid([Guid]::Parse($Component).ToString('B'));
    Contract-Assert($source.Type -eq 'Component');
    Contract-Assert($source.ClassifierID -ne 0);
    Contract-Assert($source.ParentID -ne 0);

    $parent = $ea.GetElementByID($source.ParentID);
    Contract-Assert($parent.Type -eq 'Component');

    $requiredInterfaces = $source.EmbeddedElements |? Type -eq 'RequiredInterface';
    foreach($requiredInterface in $requiredInterfaces)
    {
    	$interface = $ea.GetElementByID($requiredInterface.ClassifierID);
        Contract-Assert($interface.Type -eq 'Interface');

        $existingRequiredInterfaceOnParent = $parent.EmbeddedElements |? { $_.Type -eq 'RequiredInterface' -and $_.ClassifierID -eq $interface.ElementID };
        if(!$existingRequiredInterfaceOnParent)
        {
            Contract-Assert($existingRequiredInterfaceOnParent.Count -le 1);

            # create RequiredInterface on outside
            $existingRequiredInterfaceOnParent = $parent.EmbeddedElements.AddNew([string]::Empty, 'RequiredInterface');
            $existingRequiredInterfaceOnParent.ClassifierID = $interface.ElementID;
            $existingRequiredInterfaceOnParent.Name = $interface.Name;
            $existingRequiredInterfaceOnParent.Update();
            $parent.EmbeddedElements.Refresh();
        }

        # delete existing connector
        $connector = $existingRequiredInterfaceOnParent.Connectors |? { $_.Type -eq 'Delegate' -and $_.SupplierID -eq $requiredInterface.ElementID };
        if($connector)
        {
            Contract-Assert($connector.Count -le 1);
            
            $existingRequiredInterfaceOnParent.Connectors.Delete($connector.SequenceNo);
            $existingRequiredInterfaceOnParent.Connectors.Refresh();
        }

        # create delegate connector from outside to inside
        $connector = $existingRequiredInterfaceOnParent.Connectors.AddNew([string]::Empty, 'Delegate');
        $connector.SupplierID = $requiredInterface.ElementID;
        $connector.Update();
        $existingRequiredInterfaceOnParent.Connectors.Refresh();
    }


    # if($Force)
    # {
        # $cMax = $source.Connectors.Count;
        # for($c = 0; $c -lt $cMax; $c++)
        # {
            # $source.Connectors.Delete(0);
            # $source.Connectors.Refresh();
        # }
    # }

    # $connector = $source.Connectors.AddNew([string]::Empty, 'Realization');
	# $connector.SupplierID = $target.ElementID;

    # #$tag = $connector.TaggedValues.AddNew("biz.dfch.EA.SetInterface", '1.0.0');
    # #$tag.Update();
    # #$connector.TaggedValues.Refresh();

    # $result = $connector.Update();
    # $source.Connectors.Refresh();

    # $source.ClassifierID = $target.ElementID;
    # $source.Name = $target.Name;
    $source.Update()
}

END 
{
	$ea.CloseFile();
	$ea.Exit();
}
