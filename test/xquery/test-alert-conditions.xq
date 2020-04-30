declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";

let $input := doc("../../sample-data/alerts/input-sample-01.xml")/*/.
let $temp.tmp_alert_configuration := doc("../../sample-data/alerts/alert-configuration-fallback.xml")/*/.
let $input.AlertDetails := $input/*:parameter[@name="Alert Details"]/* 


(:we are using sub-optimal condition evaluation without using functions as the IPD expressions don't support custom funtions and function modules
This Xquery expression evaluates sets of conditions defined in the alert configuration the results can be used to decide on action
':)

(:expresion starts here:)
let $config := $temp.tmp_alert_configuration
let $alert  := $input.AlertDetails

(:
Evaluate all rules and calculate conditions result and outcome for each rule, 
the reult field is boolean determining if corresponding action associated with rule shudl be invoked:)
let $rulesEvaluated := 
        for $rule in $config/rules/rule
                    let $group-operator := $rule/operator/text()
                    let $conditions := for $condition in $rule/condition
                        let $guid           := $condition/guid/text()
                        let $fieldName      := $condition/alert-field/text()
                        let $fieldValue     := $alert/element()[local-name() = $fieldName]/text()
                        let $conditionValue := $condition/value/text()
                        let $conditionNot   := $condition/not/text()
                        let $type           := $condition/type/text()
                        let $result := switch ($type)
                                case "equals" return  $fieldValue  eq $conditionValue
                                case "matches" return matches($fieldValue,$conditionValue)
                                case "contains" return contains($fieldValue, $conditionValue)
                                default return false()
                        (:negate the conditions result when not is set to true :)
                        let $resultOut := if ($conditionNot = 'true' or $conditionNot = '0' and not(empty($conditionNot))) 
                                            then not($result) 
                                            else $result
                        return (:clone:)
                          <condition>
                              <guid>{$guid}</guid>
                              <type>{$type}</type>
                              <value>{$conditionValue}</value>
                              <fieldValue>{$fieldValue}</fieldValue>
                              <not>{$conditionNot}</not>
                              <alert-field>{$fieldName}</alert-field>
                              <result>{$resultOut}</result>
                          </condition>
                          
                  return
                  <rule>
                    <guid>{$rule/guid/text()}</guid>
                    <name>{$rule/name/text()}</name>
                    <operator>{$group-operator}</operator>
                    {$conditions}
                    {$rule/action}
                    <results>{string-join($conditions/result/text(),",")}</results>
                    <result>{ 
                        if (upper-case($group-operator) = "OR" ) then 
                            'true' = $conditions/result 
                            else (: checking if value is in the sequence of results :)
                            not( 'false' = $conditions/result) }</result>
                  </rule>
(: 
we need to decide which action to invoke following logic is applied
Eachr Rulee is associated with action that will be invoked or ignore action will be applied to specific rule
When Any rule is true with Ignore Action all other actions will be dismissed as well (ignore action is mutually exclusive with any other actions
Make sure you design rules in the way that no duplicate actions is taken two rules linked to the same action will invoke action only once
If any other action will be supported such as external event trigger,
it would be possible to combine it with email actions and they would execute in parallel 
currently email actions will be invoked sequentialy as the rules evalueted themor we will ignore the error, send Warning or Error level email
:)

(: get distinct set of actions - find all rules with true result and their actions:)
let $distinct-actions := $rulesEvaluated[result/text() = 'true']/action/guid

let $invokeActions := for $action in $config/actions/action
                      (: is value in sequence:)
                      where string($action/guid/text()) = $distinct-actions
                      return
                      $action 
                         
return
<FaultAlertConfiguration>
   {$config/alert-config}
   <rules>
       {$rulesEvaluated}
   </rules>
   {$config/actions}
   <invokeActions>{$invokeActions}</invokeActions>
</FaultAlertConfiguration>
          

