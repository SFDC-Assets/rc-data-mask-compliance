@isTest
public class RC_DataMaskCompliance_Test {

    @isTest static void test() {       
        Test.startTest();        
        System.debug('RC_DataMaskCompliance_Test >> test > start');    	        
        RC_DataMaskComplianceInvocable.checkMaskedComplianceFields();
        RC_DataMaskDeleteComplianceInvocable.deleteAllComplianceReports();        
        System.debug('GearOrderController_Test >> test > complete'); 
        Test.stopTest();
    }
    
}