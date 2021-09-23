xquery version "3.0" ;

declare namespace saxon = "http://saxon.sf.net/";


declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";

let $output := doc("../../sample-data/AgentMonitor/output.xml")/*/.
let $output.agentDetails := $output/*:field[@name="agentDetails"]/*


return 
<agents>
    {
    for $agentEngine in $output.agentDetails/agentEngines
    return
    $agentEngine/agentEngineStatus
    }
</agents>

 