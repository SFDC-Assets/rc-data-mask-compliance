trigger SyncDataMaskRunLogstoPRD on datamask__Masking_Execution_Log__c (after Insert) {
    System.debug('SyncDataMaskRunLogstoPRD > start');
    SyncDataMaskRunLogstoPRDHandler handler = new SyncDataMaskRunLogstoPRDHandler();    
    handler.onAfterInsert(Trigger.new, Trigger.newMap);
    System.debug('SyncDataMaskRunLogstoPRD > complete');
}