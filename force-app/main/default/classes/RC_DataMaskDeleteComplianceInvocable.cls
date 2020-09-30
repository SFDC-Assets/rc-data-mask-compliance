public class RC_DataMaskDeleteComplianceInvocable {

    @InvocableMethod(label='Clear Data Mask Compliance Fields' description='')
    static public void deleteAllComplianceReports() {
        RC_DataMaskCompliance.deleteAllComplianceReports();
    }
    
}