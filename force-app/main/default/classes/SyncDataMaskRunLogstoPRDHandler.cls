public with sharing class SyncDataMaskRunLogstoPRDHandler {

    public void onAfterInsert(List<datamask__Masking_Execution_Log__c> newRunLogList, Map<Id, datamask__Masking_Execution_Log__c> newRunLogMap) {
        Organization currOrg = [Select IsSandbox from Organization limit 1];
        System.debug('SyncDataMaskRunLogstoPRDHandler > isSandbox: ' + currOrg.IsSandbox);
        if( currOrg.IsSandbox) {
            Set<String> maskExecIds = new Set<String>();
            for (datamask__Masking_Execution_Log__c log : newRunLogList) {
                if (log.datamask__Type__c == 'Execution Completion') {
                    maskExecIds.add(log.datamask__Masking_Execution_Id__c);
                }
                
                syncDataMaskRunLogstoPRD(maskExecIds);               
            }
        }
        System.debug('SyncDataMaskRunLogstoPRDHandler > complete');
    }
 
	public static void syncDataMaskRunLogstoPRD(Set<String> maskExecIds) {

        System.debug('SyncDataMaskRunLogstoPRDHandler > syncDataMaskRunLogstoPRD - start');
        
		String sandboxName = UserInfo.getUserName().substringAfterLast('.'); 
        System.debug('SyncDataMaskRunLogstoPRDHandler > syncDataMaskRunLogstoPRD - sandboxName: ' + sandboxName);
        
        List<datamask_Masking_Execution_Log_c__x> prdRunLogs = new List<datamask_Masking_Execution_Log_c__x>();
        if(maskExecIds.size() > 0) {
            List<datamask__Masking_Execution_Log__c> listLogs = [Select Id,Name, datamask__Configuration_Id__c,datamask__Configuration_Name__c,datamask__Error_Message__c,datamask__Has_Master__c,datamask__Masking_Execution_Id__c,datamask__Message__c,datamask__Object_Processing__c,datamask__Record_Count_Total__c,datamask__Records_Failed__c,datamask__Records_Processed__c,datamask__Status__c,datamask__Type__c, CreatedDate, Sandbox_Org_ID__c from datamask__Masking_Execution_Log__c where datamask__Masking_Execution_Id__c IN : maskExecIds ORDER BY CREATEDDATE];
            
            for(datamask__Masking_Execution_Log__c log : listLogs) {
                datamask_Masking_Execution_Log_c__x  prdRunLog = 
                new datamask_Masking_Execution_Log_c__x(
                    datamask_Configuration_Id_c__c = log.datamask__Configuration_Id__c,
                    datamask_Configuration_Name_c__c = log.datamask__Configuration_Name__c,
                    datamask_Error_Message_c__c = log.datamask__Error_Message__c,
                    datamask_Has_Master_c__c = log.datamask__Has_Master__c,
                    datamask_Masking_Execution_Id_c__c = log.datamask__Masking_Execution_Id__c,
                    datamask_Message_c__c = log.datamask__Message__c,
                    datamask_Object_Processing_c__c = log.datamask__Object_Processing__c,
                    datamask_Record_Count_Total_c__c = log.datamask__Record_Count_Total__c,
                    datamask_Records_Failed_c__c = log.datamask__Records_Failed__c,
                    datamask_Records_Processed_c__c = log.datamask__Records_Processed__c,
                    datamask_Status_c__c = log.datamask__Status__c,
                    datamask_Type_c__c = log.datamask__Type__c,
                    Sandbox_Org_ID_c__c = log.Sandbox_Org_ID__c,
                    Sandbox_Name_c__c = sandboxName,
                    Original_Created_Date_c__c = log.CreatedDate,
                    External_Id_c__c = log.Name
                );
                
                prdRunLogs.add(prdRunLog);
            }
            
            Database.insertAsync(prdRunLogs);
            System.debug('SyncDataMaskRunLogstoPRDHandler > syncDataMaskRunLogstoPRD - run logs inserted in prod: ' + prdRunLogs.size());
        }   

    }    
    
}