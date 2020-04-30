xquery version "3.0";




declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";

let $output := doc("../../sample-data/alerts/SP-Test-Throw-Fault-Generic/output.xml")/*/.
let $output.AlertHandlerOutput := $output/*:field[@name = 'AlertHandlerOutput']/*


let $results := $output.AlertHandlerOutput[1]
return 
for $action in $results/invokeActions/action
where contains($action/Type/text(),'email')
return $action
