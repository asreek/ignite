#
# Copyright (c) 2019, Infosys Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");ttach_S1Release.robot
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

*** Settings ***
Suite Setup       Attach Suite Setup
Suite Teardown    Attach Suite Teardown
Resource          ../keywords/robotkeywords/HighLevelKeyword.robot
Resource          ../keywords/robotkeywords/MMEAttachCallflow.robot
Resource          ../keywords/robotkeywords/StringFunctions.robot

*** Test Cases ***
TC1: LTE 4G IMSI Attach Detach
    [Documentation]    Attach Detach success scenario for LTE 4G IMSI
    [Tags]    TC1    LTE_4G_IMSI_Attach_Detach    Attach    Detach
    [Setup]    Attach Test Setup
    Switch Connection    ${serverID}
    ${procStatOutBfExec1}    Execute Command    pwd
    Log    ${procStatOutBfExec1}
    Switch Connection    ${serverID}
    Sleep    1s
    ${procStatOutBfExec}    ${stderr}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s    return_stderr=True
    Log    ${procStatOutBfExec}
    ${ueCountBeforeAttach}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_subscribers_attached
    ${ueCountBeforeAttach}    Convert to Integer    ${ueCountBeforeAttach}
    ${processed_aia}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_processed_aia
    ${processed_aia}    Convert to Integer    ${processed_aia}
    ${processed_ula}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_processed_ula
    ${processed_ula}    Convert to Integer    ${processed_ula}
    ${numDelSessionReqSent}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_del_session_req_sent
    ${numDelSessionReqSent}    Convert to Integer    ${numDelSessionReqSent}
    ${numS1RelCmdSend}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_s1_rel_cmd_sent
    ${numS1RelCmdSend}    Convert to Integer    ${numS1RelCmdSend}
    ${handledEsmInfoResp}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_handled_esm_info_resp
    ${handledEsmInfoResp}    Convert to Integer    ${handledEsmInfoResp}
    ${processedSecModeResp}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_processed_sec_mode_resp
    ${processedSecModeResp}    Convert to Integer    ${processedSecModeResp}
    ${processedInitCtxtResp}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_processed_init_ctxt_resp
    ${processedInitCtxtResp}    Convert to Integer    ${processedInitCtxtResp}
    ${processedPurResp}    Get GRPC Stats Response Count    ${procStatOutBfExec}    num_of_processed_pur_resp  
    ${processedPurResp}    Convert to Integer    ${processedPurResp}
    
    Send S1ap    attach_request    ${initUeMessage_AttachReq}    ${enbUeS1APId}    ${nasAttachRequest}    ${IMSI}    #Send Attach Request to MME
    ${air}    Receive S6aMsg    #HSS Receives AIR from MME
    Validate Protocol IE    ${air}    visited-plmn-id    02f829
    Send S6aMsg    authentication_info_response    ${msgData_aia}    ${IMSI}    #HSS sends AIA to MME
    ${authReqResp}    Receive S1ap    #Auth Request received from MME
    Validate Protocol IE    ${authReqResp}    mobility_mgmt_message_type    authentication_request
    Send S1ap    uplink_nas_transport_authresp    ${uplinkNASTransport_AuthResp}    ${enbUeS1APId}    ${nasAuthenticationResponse}    #Send Auth Response to MME
    ${secModeCmdRecd}    Receive S1ap    #Security Mode Command received from MME
    Send S1ap    uplink_nas_transport_secMode_cmp    ${uplinkNASTransport_SecModeCmp}    ${enbUeS1APId}    ${nasSecurityModeComplete}    #Send Security Mode Complete to MME
    ${esmInfoReq}    Receive S1ap    #ESM Information Request from MME
    Send S1ap    esm_information_response    ${uplinknastransport_esm_information_response}    ${enbUeS1APId}    ${nas_esm_information_response}    #ESM Information Response to MME
    ${ulr}    Receive S6aMsg    #HSS receives ULR from MME
    Send S6aMsg     update_location_response    ${msgData_ula}    ${IMSI}   #HSS sends ULA to MME
    ${createSessReqRecdFromMME}    Receive GTP    #Create Session Request received from MME
    Validate Protocol IE    ${createSessReqRecdFromMME}    apn    apn1
    Validate Protocol IE    ${createSessReqRecdFromMME}    pdn_type    1
    Send GTP    create_session_response    ${createSessionResp}    ${gtpMsgHeirarchy_tag1}    #Send Create Session Response to MME
    ${intContSetupReqRec}    Receive S1ap    #Initial Context Setup Request received from MME
    Send S1ap    initial_context_setup_response    ${initContextSetupRes}    ${enbUeS1APId}    #Send Initial Context Setup Response to MME
    Sleep    1s
    Send S1ap    uplink_nas_transport_attach_cmp    ${uplinkNASTransport_AttachCmp}    ${enbUeS1APId}    ${nasAttachComplete}    #Send Attach Complete to MME
    ${modBearReqRec}    Receive GTP    #Modify Bearer Request received from MME
    Send GTP    modify_bearer_response    ${modifyBearerResp}    ${gtpMsgHeirarchy_tag2}    #Send Modify Bearer Response to MME
    Sleep    1s
    ${mmeUeS1APId}    ${mmeUeS1APIdPresent}    Get Key Value From Dict    ${intContSetupReqRec}    MME-UE-S1AP-ID
    ${IMSI_str}    Convert to String    ${IMSI}
    ${mobContextAftExec}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show mobile-context ${mmeUeS1APId}    timeout=30s
    Log    ${mobContextAftExec}
    Should Contain    ${mobContextAftExec}    ${IMSI_str}    Expected IMSI: ${IMSI_str}, but Received ${mobContextAftExec}    values=False
    Should Contain    ${mobContextAftExec}    EpsAttached    Expected UE State: EpsAttached, but Received ${mobContextAftExec}    values=False
    ${procStatOutAfAttach}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s
    Log    ${procStatOutAfAttach}
    ${ueCountAfterAttach}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_subscribers_attached
    ${ueCountAfterAttach}    Convert to Integer    ${ueCountAfterAttach}
    ${incrementUeCount}    Evaluate    ${ueCountBeforeAttach}+1
    Should Be Equal    ${incrementUeCount}    ${ueCountAfterAttach}    Expected UE Attach Count: ${incrementUeCount}, but Received UE Attach Count: ${ueCountAfterAttach}    values=False
    ${processedInitCtxtRespAf}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_processed_init_ctxt_resp
    ${processedInitCtxtRespAf}    Convert to Integer    ${processedInitCtxtRespAf}
    ${incrementProcessedInitCtxtRespCount}    Evaluate    ${processedInitCtxtResp}+1
    Should Be Equal    ${incrementProcessedInitCtxtRespCount}    ${processedInitCtxtRespAf}    Expected Init Ctxt Resp Count: ${incrementProcessedInitCtxtRespCount}, but Received Init Ctxt Resp Count: ${processedInitCtxtRespAf}    values=False
    ${handledEsmInfoRespAf}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_handled_esm_info_resp
    ${handledEsmInfoRespAf}    Convert to Integer    ${handledEsmInfoRespAf}
    ${incrementhandledEsmInfoRespCount}    Evaluate    ${handledEsmInfoResp}+1
    Should Be Equal    ${incrementhandledEsmInfoRespCount}    ${handledEsmInfoRespAf}    Expected Esm Info Resp Count: ${incrementhandledEsmInfoRespCount}, but Received Esm Info Resp Count: ${handledEsmInfoRespAf}    values=False
    ${processedSecModeRespAf}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_processed_sec_mode_resp
    ${processedSecModeRespAf}    Convert to Integer    ${processedSecModeRespAf}
    ${incProcessedSecModeRespCount}    Evaluate    ${processedSecModeResp}+1
    Should Be Equal    ${incProcessedSecModeRespCount}    ${processedSecModeRespAf}    Expected Sec Mode Resp Count: ${incProcessedSecModeRespCount}, but Received Sec Mode Resp Count: ${processedSecModeRespAf}    values=False
    ${processed_aiaAf}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_processed_aia
    ${processed_aiaAf}    Convert to Integer    ${processed_aiaAf}
    ${incprocessed_aiaCount}    Evaluate    ${processed_aia}+1
    Should Be Equal    ${incprocessed_aiaCount}    ${processed_aiaAf}    Expected processed aia Count: ${incprocessed_aiaCount}, but Received processed aia Resp Count: ${processed_aiaAf}    values=False
    ${processed_ulaAf}    Get GRPC Stats Response Count    ${procStatOutAfAttach}    num_of_processed_ula
    ${processed_ulaAf}    Convert to Integer    ${processed_ulaAf}
    ${incprocessed_ulaAfCount}    Evaluate    ${processed_ula}+1
    Should Be Equal    ${incprocessed_ulaAfCount}    ${processed_ulaAf}    Expected processed ula Count: ${incprocessed_ulaAfCount}, but Received processed ula Count: ${processed_ulaAf}    values=False
    Send S1ap    detach_request    ${uplinkNASTransport_DetachReq}    ${enbUeS1APId}    ${nasDetachRequest}    #Send Detach Request to MME
    ${delSesReqRec}    Receive GTP    #Delete Session Request received from MME
    ${purgeRequest}    Receive S6aMsg    #HSS receives Purge Request from MME
    Send GTP    delete_session_response    ${deleteSessionResp}    ${gtpMsgHeirarchy_tag3}    #Send Delete Session Response to MME
    Send S6aMsg     purge_response    ${msgData_pua}    ${IMSI}   #HSS sends Purge Response to MME
    ${detAccUE}    Receive S1ap    #MME send Detach Accept to UE
    ${eNBUeRelReqFromMME}    Receive S1ap    #eNB receives UE Context Release Request from MME
    Send S1ap    ue_context_release_cmp    ${ueContextReleaseCmp}    ${enbUeS1APId}    #eNB sends UE Context Release Complete to MME
    Sleep    1s
    ${procStatOutAfDetach}    Execute Command    export LD_LIBRARY_PATH=${openMmeLibPath} && ${mmeGrpcClientPath}/mme-grpc-client mme-app show procedure-stats    timeout=30s
    Log    ${procStatOutAfDetach}
    ${ueCountAfterDetach}    Get GRPC Stats Response Count    ${procStatOutAfDetach}    num_of_subscribers_attached
    ${ueCountAfterDetach}    Convert to Integer    ${ueCountAfterDetach}
    Should Be Equal    ${ueCountBeforeAttach}    ${ueCountAfterDetach}    Expected UE Detach Count: ${ueCountBeforeAttach}, but Received UE Detach Count: ${ueCountAfterDetach}    values=False
    ${numDelSessionReqSentAfterDetach}    Get GRPC Stats Response Count    ${procStatOutAfDetach}    num_of_del_session_req_sent
    ${numDelSessionReqSentAfterDetach}    Convert to Integer    ${numDelSessionReqSentAfterDetach}
    ${inc_numDelSessionReqSent}    Evaluate    ${numDelSessionReqSent}+1
    Should Be Equal    ${inc_numDelSessionReqSent}    ${numDelSessionReqSentAfterDetach}    Expected num Del Session Req Sent After Detach: ${inc_numDelSessionReqSent}, but Received num Del Session Req Sent After Detach: ${numDelSessionReqSentAfterDetach}    values=False
    ${processedPurRespAf}    Get GRPC Stats Response Count    ${procStatOutAfDetach}    num_of_processed_pur_resp  
    ${processedPurRespAf}    Convert to Integer    ${processedPurRespAf}
    ${incprocessedPurResp}    Evaluate    ${processedPurResp}+1
    Should Be Equal    ${incprocessedPurResp}    ${processedPurRespAf}    Expected num Pur Processed Response After Detach: ${incprocessedPurResp}, but Received num Pur Processed Response After Detach: ${processedPurRespAf}    values=False
    [Teardown]    Attach Test Teardown
    
