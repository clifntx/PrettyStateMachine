#Load SharePoint CSOM Assemblies
[System.Reflection.Assembly]::LoadFile(“<dllPath>\Microsoft.SharePoint.Client.dll”) | Out-Null
[System.Reflection.Assembly]::LoadFile(“<dllPath>\Microsoft.SharePoint.Client.Runtime.dll”) | Out-Null

#$SiteUrl = “https://emiratesgroup.sharepoint.com/sites/spdev&#8221;
$Password = ConvertTo-SecureString “<enter pswd here>” -AsPlainText –Force
$User = “jo@domain.com”
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User, $Password)

$SiteUrl = $object.SiteCollection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $credentials
$spoSite = $Context.Site
$Context.Load($spoSite)
$Audit = $spoSite.Audit
$Context.Load($Audit)
$Context.ExecuteQuery()

$All = [Microsoft.SharePoint.Client.AuditMaskType]::All;
$None = [Microsoft.SharePoint.Client.AuditMaskType]::None;
$CheckIn = [Microsoft.SharePoint.Client.AuditMaskType]::CheckIn;
$CheckOut = [Microsoft.SharePoint.Client.AuditMaskType]::CheckOut;
$ChildDelete = [Microsoft.SharePoint.Client.AuditMaskType]::ChildDelete;
$CheckIn = [Microsoft.SharePoint.Client.AuditMaskType]::CopyCheckIn;
$Move = [Microsoft.SharePoint.Client.AuditMaskType]::Move;
$ObjectDelete = [Microsoft.SharePoint.Client.AuditMaskType]::ObjectDelete;
$ProfileChange = [Microsoft.SharePoint.Client.AuditMaskType]::ProfileChange;
$SchemaChange = [Microsoft.SharePoint.Client.AuditMaskType]::SchemaChange;
$Search = [Microsoft.SharePoint.Client.AuditMaskType]::Search;

$SecurityChange = [Microsoft.SharePoint.Client.AuditMaskType]::SecurityChange;
$Undelete = [Microsoft.SharePoint.Client.AuditMaskType]::Undelete;
$Update = [Microsoft.SharePoint.Client.AuditMaskType]::Update;
$View = [Microsoft.SharePoint.Client.AuditMaskType]::View;
$Workflow = [Microsoft.SharePoint.Client.AuditMaskType]::Workflow;

$Audit.AuditFlags = $Update, $Undelete, $SecurityChange
$Audit.Update()
$spoSite.AuditLogTrimmingRetention = 90
$spoSite.TrimAuditLog = $true
$Audit.Update()
$Context.ExecuteQuery()
write-host “updated for site:” $object.SiteCollection