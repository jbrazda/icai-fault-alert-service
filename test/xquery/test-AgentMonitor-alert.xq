xquery version "3.0" ;

declare namespace saxon = "http://saxon.sf.net/";


declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";

let $output := doc("../../sample-data/AgentMonitor/output.xml")/*/.
let $output.agentDetails := $output/*:field[@name="agentDetails"]/*

let $input.in_configuration := <AgentMonitor>
         <agentServices>Administrator,Common Integration Components,Data Integration Server,Mass Ingestion,OI Data Collector,Process Server</agentServices>
         <actions>
            <email>
               <subject>Warning - Unexpected Agent State</subject>
               <to>jbrazda@unicosolution.com</to>
            </email>
         </actions>
      </AgentMonitor>

let $temp.tmp_base_uri             := "https://na1.ai.dm-us.informaticacloud.com"
let $temp.tmp_admin_base_uri       := "https://na1.dm-us.informaticacloud.com"
let $temp.tmp_org_id               := "d8UL5i5Pm4KddufpfKuiaN"
let $temp.tmp_environment_name     := "Cloud Dev"

(:Expression Start:)
let $configuration := $input.in_configuration
let $expected_services := tokenize($configuration/agentServices/text(), ',')
let $environment := $temp.tmp_environment_name
let $org_id := $temp.tmp_org_id
let $format-date := "[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]"
let $agentDetails := ($output.agentDetails)

return 
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="Generator" content="Informatica Cloud" />
        <title>Agent Monitor Notification</title>
        <style type="text/css" media="screen">

            body {{
                font-size: 12px;
                font-family: arial, sans-serif;
                width: 100% !important;
                -webkit-text-size-adjust: 100%;
                -ms-text-size-adjust: 100%;
                margin: 0;
                padding: 0;
            }}
            
            /* Prevent Webkit and Windows Mobile platforms from changing default font sizes, while not breaking desktop design. */
            .ExternalClass {{
                width: 100%;
            }}
            
            /* Force Hotmail to display emails at full width */
            .ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font,.ExternalClass td,.ExternalClass div
                {{
                line-height: 100%;
            }}
            /* Force Hotmail to display normal line spacing.  More on that: http://www.emailonacid.com/forum/viewthread/43/ */
            #backgroundTable {{
                margin: 0;
                padding: 0;
                width: 100% !important;
                line-height: 100% !important;
            }}
            
            p {{
                font-size: 12px;
                font-family: inherit;
            }}
            
            ul {{
                list-style-type: disc;
            }}
            
            li {{
                font-size: 12px;
                font-family: arial, sans-serif;
            }}
            
            table{{
               table-layout: fixed;
               width: 100%;
            }}
            
            table td {{
                border-collapse: collapse;
                font-size: 12px;
                background-color: inherit;
                color: inherit;
            }}
            
            td.center {{
                text-align: center;
                white-space: nowrap;
            }}
            
            th {{
                font-size: 12px;
                font-weight: bold;
                background-color: #ddd;
            }}
            

            .info-msg,
            .success-msg,
            .warning-msg,
            .error-msg {{
              margin: 12px 0;
              padding: 12px;
              border-radius: 3px 3px 3px 3px;
            }}
            
            .info-msg {{
              color: #059;
              background-color: #BEF;
            }}
            .success-msg {{
              color: #270;
              background-color: #DFF2BF;
            }}
            .warning-msg {{
              color: #9F6000;
              background-color: #FEEFB3;
            }}
            .error-msg {{
              color: #D8000C;
              background-color: #FFBABA;
            }}
            
    </style>
        
    </head>
    <body style="background: #E4E4E4">
    <table id="backgroundTable" align="center"
        style="background: #FFFFFF; border: 12px solid #FFFFFF; width: 90%; border-collapse: collapse; padding: 12px; font-size: 10pt; font-family: Arial, sans-serif;">
        <tr style="background: #000000; color: #FFFFFF;">
            <td style="padding: 8px; padding-left: 12px; color: #FFFFFF;"><b>Agent Monitor Notification</b></td>
            <td style="padding: 8px; padding-right: 12px; text-align: right; color: #FFFFFF;"><b><i>Org:{$org_id} Env:{$environment}</i></b></td>
        </tr>
        <tr>
            <td colspan="2"
                style="padding: 0px; padding-top: 12px; background: #FFFFFF; font-size: 10pt;">
                <table id="messageTable"
                    style="padding: 0px; border: 0px; width: 100%; background: #F4F4F4; color: #2F2F2F; font-size: 10pt; font-family: Arial, sans-serif;">
                    <tr>
                        <td style="padding: 2em">
                            { 
                            for $agent in $agentDetails return
                            let $view_url := concat($temp.tmp_admin_base_uri,"/cloudUI/products/administer/main/SecureAgentDetailsWS/",$agent/id/text(),"/read")
                            let $services := ($agent/agentEngines/agentEngineStatus/appDisplayName/text())
                            let $services_running := ($agent/agentEngines[agentEngineStatus/status/text() = "RUNNING"])
                            let $count_running  := count($services_running)
                            let $count_services := count($services)
                            let $count_expected := count($expected_services)
                            
                            return
                            <div id="alert_info" style="display: block;">
                         
                            <h2>Agent Status Alert</h2>
                            {if (exists($agent/agentEngines[agentEngineStatus/status/text() != "RUNNING"])
                                or $count_expected != $count_running)
                            then
                            <div class="warning-msg">
                               &#x26a0; <strong>Warning!</strong> Not All Services Are Running!
                            </div>
                            else ()
                            }
                            <table id="agent_table" align="left"
                                style="width: 100%; ; border: 1px; font-size: 10pt; font-family: Arial, sans-serif; table-layout: fixed;">
                                <tr>
                                    <td style="width: 150px">Agent Name</td>
                                    <td><a href="{$view_url}">{$agent/name/text()}</a></td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Agent Host</td>
                                    <td>{$agent/agentHost/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Active</td>
                                    <td>{$agent/active/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Services Status</td>
                                    <td>Running {$count_running} out of {$count_expected} expected services</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Platform</td>
                                    <td>{$agent/platform/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Last Status Change</td>
                                    <td>{$agent/lastStatusChange/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Update Time</td>
                                    <td>{$agent/updateTime/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Last Upgraded</td>
                                    <td>{$agent/lastUpgraded/text()}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Agent Version</td>
                                    <td>{$agent/agentVersion/text()}</td>
                                </tr>
                            </table>
                            <div id="service_list" style="padding-top:2em; margin-bottom: 1em; margin-top: 2em; display: inline-table; width: 100%;">
                                <h2>Services</h2>
                                <table id="agent_table" 
                                    align="left"
                                    style="width: 100%; border: 1px; font-size: 10pt; font-family: Arial, sans-serif; table-layout: fixed;">
                                    <tr>
                                        <th>Service Name</th>
                                        <th>Current Status</th>
                                        <th>Desired Status</th>
                                    </tr>
                                    {
                                    for $service in $agent/agentEngines
                                        let $agentEngineStatus := $service/agentEngineStatus
                                        let $appDisplayName :=  $agentEngineStatus/appDisplayName/text()
                                        let $status := if (empty($agentEngineStatus/status/text())) then 'STOPPED'
                                                       else $agentEngineStatus/status/text()
                                        (:Unicode  characters to represent status 
                                        U+1F7E2; RUNNING &#x1f7e2;
                                        U+1F7E0; OTHER   &#x1F7E0;
                                        U+1F534; ERROR   &#x1f534;
                                        :)
                                        let $status_label := switch ($status)
                                                        case 'RUNNING' return '&#x1f7e2;'
                                                        case 'STOPPED' return '&#x1f6d1;'
                                                        case 'ERROR' return '&#x1f534;'
                                                        default return '&#x1f7e0;'

                                        let $desiredStatus := if (empty($agentEngineStatus/desiredStatus/text())) then 'STOPPED'
                                                              else $agentEngineStatus/desiredStatus/text()
                                        where $appDisplayName = $expected_services
                                    return
                                    <tr>
                                        <td>{ $appDisplayName }</td>
                                        <td>{ $status_label }{' '}{$status}</td>
                                        <td>{ $desiredStatus }</td>
                                    </tr>
                                    }
                                 </table>
                            </div> <!-- END service_list -->
                            </div>
                            }
                         </td>
                    </tr>
                </table> <!-- END  messageTable-->
            </td>
        </tr>
    </table> <!--END backgroundTable-->
    </body>
</html>

