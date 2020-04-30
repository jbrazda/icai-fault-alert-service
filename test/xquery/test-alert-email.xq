xquery version "3.0";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
(:
  Copyright (c) 2017 Informatica Corporation
  This code is free software: you can redistribute it and/or modify it

  Unless required by applicable law or agreed to in writing, software
  is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
  ANY KIND, either express or implied.
:)
(:~
: @author jbrazda
: @since June 2019
: @version 1.0
:)
declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";



(:Process Variables Context:)

let $input := doc("../../sample-data/alerts/SP-Test-Throw-Fault-Generic/input.xml")/*/.
(:
let $temp   := doc("../../sample-data/MP-Ariba-External-Approval-Job/Report-Email/FullLoadReProcess/temp.xml")/*/.
let $input  := doc("../../sample-data/MP-Ariba-External-Approval-Job/Report-Email/FullLoadReProcess/input.xml")/*/.
:)

let $output.AlertHandlerOutput     := doc("../../sample-data/alerts/alert-configuration-results.xml")/*/.
let $input.AlertDetails            := $input/*:parameter[@name = 'Alert Details']/*
let $temp.tmp_email_action_details := doc("../../sample-data/alerts/temp.tmp_email_action_details.xml")/*/.
let $temp.tmp_base_uri             := "https://na1.ai.dm-us.informaticacloud.com"
let $temp.tmp_org_id               := "d8UL5i5Pm4KddufpfKuiaN"
let $temp.tmp_environment_name     := "iclab"



(:Copy Expression Starts Here:)
let $org_id := $temp.tmp_org_id
let $environment := $temp.tmp_environment_name 
let $base_uri := $temp.tmp_base_uri
let $alert := $input.AlertDetails
let $current-time := current-date()
let $date_format  := "[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]:[f01]"

let $processId := $alert/processId/text()
let $processName := $alert/processName/text()
let $faultNamespace := $alert/faultNamespace/text()
let $processInitiator := $alert/processInitiator/text()
let $processNamespace := $alert/processNamespace/text()
let $locationPath := $alert/locationPath/text()
let $status := $alert/status/text()
let $faultName := $alert/faultName/text()
(:trying to parse fault details if XML and pretty print:)

let $serialization-params := <xsl:output 
                                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                xmlns:saxon="http://saxon.sf.net/"
                                method="xml"
                                omit-xml-declaration="yes"
                                indent="yes"
                                saxon:indent-spaces="4"/>
let $faultDetails :=   try { saxon:serialize(fn:parse-xml($alert/faultDetails/text()),$serialization-params )
                        } catch * {
                          $alert/faultDetails/text()
                        }

(:generate Process Link:)

let $view_url :=  if (contains($environment, "Cloud"))
    then concat($base_uri,"/activevos-central/projres/apps/app-integration/integrationConsole/index.html#/main/processinstance/",$processId,"/",$processName,"-",$processId,"%7B%7D")
    else concat($base_uri,"/activevos-central/projres/apps/app-integration/integrationConsole/index.html#/main/processinstance/",$processId,"/",$processName,"-",$processId,"%7B",$environment,"%7D")

return
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="Generator" content="Informatica Cloud" />
        <title>Integration Job Notification</title>
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
    </style>
        
    </head>
    <body style="background: #E4E4E4">
    <table id="backgroundTable" align="center"
        style="background: #FFFFFF; border: 12px solid #FFFFFF; width: 90%; border-collapse: collapse; padding: 10px; font-size: 10pt; font-family: Arial, sans-serif;">
        <tr style="background: #000000; color: #FFFFFF;">
            <td style="padding: 8px; padding-left: 12px; color: #FFFFFF;"><b>Fault Alert Notification</b></td>
            <td style="padding: 8px; padding-right: 12px; text-align: right; color: #FFFFFF;"><b><i>Org:{$org_id} Env:{$environment}</i></b></td>
        </tr>
        <tr>
            <td colspan="2"
                style="padding: 0px; padding-top: 10px; background: #FFFFFF; font-size: 10pt;">
                <table id="messageTable"
                    style="padding: 0px; border: 0px; width: 100%; background: #F4F4F4; color: #2F2F2F; font-size: 10pt; font-family: Arial, sans-serif;">
                    <tr>
                        <td style="padding: 2em">
                            <div id="job_info" style="display: block;">
                            <h2>Unexpected Error {$processName}</h2>
                            <table id="AlertTable" align="left"
                                style="width: 100%; ; border: 1px; font-size: 10pt; font-family: Arial, sans-serif; table-layout: fixed;">
                                <tr>
                                    <td style="width: 150px">Process Id</td>
                                    <td><a href="{$view_url}">{$processId}</a></td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Process Name</td>
                                    <td>{$processName}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Process Namespace</td>
                                    <td>{$processNamespace}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Fault Location Path</td>
                                    <td>{$locationPath}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Fault Name</td>
                                    <td>{$faultName}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Fault Namespace</td>
                                    <td>{$faultNamespace}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Proccess Initiator</td>
                                    <td>{$processInitiator}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Process Status</td>
                                    <td>{$status}</td>
                                </tr>
                            </table>
                            </div>
                            {if (empty($faultDetails)) then () else 
                            <div id="item_list" style="padding-top:2em; margin-bottom: 1em; margin-top: 2em; display: block; width: 100%;">
                                <h2>Fault Detail</h2>
                                <textarea rows="20" style="width: 100%; height: 300px; font-family: Consolas,'Courier New', Courier, monospace">
                                    {$faultDetails}
                                </textarea>
                            </div>
                            } 
                         </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </body>
</html>