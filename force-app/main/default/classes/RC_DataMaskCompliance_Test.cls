@isTest
public class RC_DataMaskCompliance_Test {

    @isTest static void test() {            
        System.debug('RC_DataMaskCompliance_Test >> test > start');    	        
        RC_DataMaskComplianceInvocable.checkMaskedComplianceFields();
        RC_DataMaskDeleteComplianceInvocable.deleteAllComplianceReports();        
        System.debug('RC_DataMaskCompliance_Test >> test > complete'); 
    }
    
}