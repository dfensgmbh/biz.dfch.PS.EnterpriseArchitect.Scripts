PARAM
(
	[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[object] $InputObject
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

$PSDefaultParameterValues.'Add-ClientForInterface.ps1:Model' = 'C:\myModel.EAP'
 #>

BEGIN 
{
	$OutputParameter = $null;

	$EaInteropPathAndFileName = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath $EaInterop;
	Add-Type -Path $EaInteropPathAndFileName;

    $parameters = @{};
    $parameters.Repository = New-Object -ComObject EA.Repository;

	$result = $parameters.Repository.OpenFile($Model);
    Contract-Assert(!!$result, $EaInteropPathAndFileName);
}

PROCESS 
{
    trap { Log-Exception $_; break; }
 
    function ProcessProvidedInterface
    {
        Param
        (
            $ProvidedInterface, 
            [hashtable] $P
        )

        $createNewComponent = $true;

	    $source = $P.Repository.GetElementByGuid([Guid]::Parse($ProvidedInterface).ToString('B'));
        Contract-Assert($source.Type -eq 'ProvidedInterface');

        if(!$P.ContainsKey('Server'))
        {
            $P.Server = $P.Repository.GetElementByID($source.ParentID);
            Contract-Assert($P.Server.Type -eq 'Component');
        }
        else
        {
            Contract-Assert($source.ParentID -eq $P.Server.ElementID);
        }

        if(!$P.ContainsKey('Package'))
        {
            $P.Package = $P.Repository.GetPackageByID($source.PackageID);
        }
        else
        {
            Contract-Assert($source.PackageID -eq $P.Package.PackageID);
        }

        $interface = $P.Repository.GetElementByID($source.ClassifierID);
        Contract-Assert($interface.Type -eq 'Interface');

        $connectors = $P.Server.Connectors |? Type -eq 'Usage';
        :connectors foreach($connector in $connectors) 
        { 
	        $client = $P.Repository.GetElementByID($connector.ClientID);
	        if($client.Type -ne 'Component')
	        {
		        continue;
	        }
	
	        $requiredInterfaces = $client.EmbeddedElements |? Type -eq 'RequiredInterface';
	        :requiredInterfaces foreach($requiredInterface in $requiredInterfaces) 
	        { 
		        if($requiredInterface.ClassifierID -ne $source.ClassifierID) 
		        {
                    continue;
		        }

			    $requiredInterface.Name = $interface.Name;
			    $result = $connector.Update();
			    $source.Connectors.Refresh();
                $source.Update()
			
                $P.Component = $client;

			    break connectors;
	        }
        }


        if(!$P.ContainsKey('Component'))
        {
            # create a new component

            $componentName = [string]::Format("{0} Clt", $P.Server.Name);
            $P.Component = $P.Package.Elements.AddNew($componentName, "Component");
            $P.Component.Update();
    
            $P.Package.Elements.Refresh();

            # create deployment spec
            $deploymentSpecName = [string]::Format('{0} Spec', $P.Component.Name);
            $deploymentSpec = $P.Package.Elements.AddNew($deploymentSpecName, 'DeploymentSpecification');
            $P.Component.Update();
            $P.Package.Elements.Refresh();

            # create dependency between deployment spec and component 
            $dependency = $deploymentSpec.Connectors.AddNew([string]::Empty, 'Dependency');
            $dependency.SupplierID = $P.Component.ElementID;
            $result = $dependency.Update();

            $P.Component.Connectors.Refresh();

            # create Usage connector from Component to Server
            $connector = $P.Component.Connectors.AddNew([string]::Empty, 'Usage');
            $connector.SupplierID = $P.Server.ElementID;

            $result = $connector.Update();
            Contract-Assert($result);
        }
        
        # create a RequiredInterface
        $requiredInterface = $P.Component.EmbeddedElements.AddNew($interface.Name, 'RequiredInterface');

        # link Required Interface to Interface
        $requiredInterface.ClassifierID = $interface.ElementID;
        $requiredInterface.Name = $interface.Name;

        $requiredInterface.Update();
        $P.Component.EmbeddedElements.Refresh();
    }
   
    foreach($providedInterface in $InputObject)
    {
        $result = ProcessProvidedInterface -ProvidedInterface $providedInterface -P $parameters;
    }

}

END 
{
	$parameters.Repository.CloseFile();
	$parameters.Repository.Exit();
}
