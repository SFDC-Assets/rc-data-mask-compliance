public class RC_DataMaskCompliance {

    @Future
    static public void checkMaskedComplianceFields() {
        
        System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields - start');
        
        clearLatestFlagOnLastReport();
        
        Map<String, List<FieldDefinition>> complianceEntityFieldMap = getEntityFieldMap();
        Map<String, List<RC_DataMaskField>> maskedEntityFieldMap = getMaskedEntityFieldMap();
        
        List<RC_DM_Compliance_Field__c> reportEntries = new List<RC_DM_Compliance_Field__c>();
        DateTime reportDate = System.now();
        String reportID = reportDate.format('yyyy-dd-MM hh:mm');
        
        // loop through fields with a compliance categorization and check if there is a masking policy for them		
        for (String entityName : complianceEntityFieldMap.keySet()) {
         
            System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields - checking compliance fields are masked for object: ' + entityName);
            List<FieldDefinition> complianceFields = complianceEntityFieldMap.get(entityName);
            
            for (FieldDefinition complianceField : complianceFields) {
                String complianceFieldName = complianceField.QualifiedApiName;
            	boolean masked = false;
                
                RC_DM_Compliance_Field__c reportEntry = new RC_DM_Compliance_Field__c(Report_ID__c = reportID,
                    																  Report_Date__c = reportDate,
                                                                                      Latest_Report__c = true,
                                                                                      Object_Name__c = entityName,
                                                                                      Field_Name__c = complianceFieldName,
                                                                                      ComplianceGroup__c = complianceField.ComplianceGroup,
                                                                                      BusinessStatus__c = complianceField.BusinessStatus,
                                                                                      SecurityClassification__c = complianceField.SecurityClassification
                                                                                     );
               
                // masked fields for this entity
                List<RC_DataMaskField> maskedFields = maskedEntityFieldMap.get(entityName);
                if (maskedFields == null) {
                    // no masked fields for this object that has compliance fields
                } else {
                    // check for matching masking policy for compliance fields
                    
                    for (RC_DataMaskField maskedField : maskedFields) {
                        if (maskedField.fieldApiName == complianceFieldName) {
                            masked = true;
                            reportEntry.DM_Config__c = maskedField.dmConfigName;
                            reportEntry.Masking_Type__c = maskedField.maskingType;
                            reportEntry.Field_Type__c = maskedField.fieldType;
                            reportEntry.Masking_Category__c = maskedField.maskingCategory;
                        }
                    }
                }
                if (masked) {
                    System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields >> compliance field (' + complianceFieldName + ') is masked');
                } else {
                    System.debug(' RC_DataMaskCompliance > checkMaskedComplianceFields >> compliance field (' + complianceFieldName + ') is NOT masked');
                }
                reportEntry.isMasked__c = masked;
                reportEntries.add(reportEntry);
            }
        
        }
        
        System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields - reportEntries: ' + reportEntries.size()); 
        for (RC_DM_Compliance_Field__c entry : reportEntries) {
            System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields - reportEntry: ' + entry);
        }
       
        // insert report entries
        insert reportEntries;
        
        System.debug('RC_DataMaskCompliance > checkMaskedComplianceFields - complete');
        
    } // checkMaskedComplianceFields
    
    static public Map<String, List<RC_DataMaskField>> getMaskedEntityFieldMap() {
        
        System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap - start');
        
        List<datamask__DataMask_Configuration__mdt> configs = [SELECT Id, DeveloperName
                                                               //(SELECT Id, DeveloperName, MasterLabel FROM datamask__Masking_Objects__r)
                                                               FROM datamask__DataMask_Configuration__mdt];
        System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap - configs: (' + configs.size() + ') ' + configs);
        
        // map of <entity name, List of masked fields>
        Map<String, List<RC_DataMaskField>> entityFieldMap = new Map<String, List<RC_DataMaskField>>();
        
        for (datamask__DataMask_Configuration__mdt config : configs) {
                        
            List<datamask__Masking_Object__mdt> maskingObjects = [SELECT Id, datamask__API_Name__c FROM datamask__Masking_Object__mdt WHERE datamask__DataMask_Configuration__c = :config.Id];
        	System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap > config: ' + config.DeveloperName + ' - masking objects: ' + maskingObjects.size());
            
            for (datamask__Masking_Object__mdt maskingObject : maskingObjects) {
                System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap >> masking object: ' + maskingObject);
                
                List<datamask__Masking_Field__mdt> maskingFields = [SELECT Id, datamask__API_Name__c, datamask__Masking_Type__c, datamask__Field_Type__c, 
                                                                    datamask__Field_Length__c, datamask__Masking_Category__c
                                                                    FROM datamask__Masking_Field__mdt WHERE datamask__Masking_Object__c = :maskingObject.Id];
                
                // convert from datamask__Masking_Field__mdt to apex type RC_DataMaskField
                List<RC_DataMaskField> dmFields = new List<RC_DataMaskField>();
                for (datamask__Masking_Field__mdt field : maskingFields) {
                    RC_DataMaskField dmField = new RC_DataMaskField();
                    dmField.objectApiName = maskingObject.datamask__API_Name__c;
                    dmField.dmConfigName = config.DeveloperName;
                    dmField.fieldApiName = field.datamask__API_Name__c;
                    dmField.fieldType = field.datamask__Field_Type__c;
                    dmField.maskingType = field.datamask__Masking_Type__c;
                    dmField.maskingCategory = field.datamask__Masking_Category__c;
                    dmFields.add(dmField);
                }
				System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap - masking fields: ' + dmFields.size());                
                
                // put object and fields in map
                entityFieldMap.put(maskingObject.datamask__API_Name__c, dmFields);
                
                for (RC_DataMaskField dmField : dmFields) {
                    System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap >>> masking field: ' + dmField);
                } 
            }            
        }
        
        System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap - masked entityFieldMap: ' + entityFieldMap.size());
        for (String key : entityFieldMap.keySet()) {
            System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap > masked fields for object: ' + key);
            List<RC_DataMaskField> maskedFields = entityFieldMap.get(key);           
            for (RC_DataMaskField field : maskedFields) {
                System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap >> ' + field);
            }
        }
        System.debug('RC_DataMaskCompliance > getMaskedEntityFieldMap - complete');
                     
        return entityFieldMap;
        
    } // end getMaskedEntityFieldMap
    
    static public Map<String, List<FieldDefinition>> getEntityFieldMap() {
        
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - start');
        
        List<EntityDefinition> allEntities = [SELECT DurableId, DeveloperName, MasterLabel, QualifiedApiName 
                                              FROM EntityDefinition WHERE IsCustomSetting = false ORDER BY DeveloperName];
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - allEntities: (' + allEntities.size() + ')');
        
        // filter out meta objects
        List<String> entityNames = new List<String>();
        Map<String, EntityDefinition> entities = new Map<String, EntityDefinition>();
        for (EntityDefinition entity : allEntities) {
            if (entity.MasterLabel.startsWith('History:') 
                || entity.MasterLabel.startsWith('Change Event:') 
                || entity.MasterLabel.startsWith('Share:') 
                || entity.MasterLabel.startsWith('Feed:') 
                || entity.MasterLabel.startsWith('Tag:')){}
            else { 
                entityNames.add(entity.QualifiedApiName);
                entities.put(entity.DurableId, entity);
            }
        }
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - entity names: (' + entityNames.size() + ')');
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - filtered entities: (' + entities.size() + ')');       
        
        /*
        for (EntityDefinition entity : entities.values()) {
            Integer i = 0;
            System.debug(++i + ': ' + entity);
        }
		*/
        
        List<FieldDefinition> fieldDefinitions = [SELECT DurableId, EntityDefinitionId, DeveloperName, QualifiedApiName, 
                                                  BusinessStatus, SecurityClassification, ComplianceGroup  
                                                  FROM FieldDefinition 
                                                  WHERE EntityDefinition.QualifiedApiName IN :entityNames AND ComplianceGroup != NULL
                                                 ];
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - fieldDefinitions: ' + fieldDefinitions.size());
        
        // map <Entity.Id, List of FieldDefinition>
        Map<String, List<FieldDefinition>> entityFieldMap = new Map<String, List<FieldDefinition>>();        
        for (FieldDefinition field : fieldDefinitions) {
            List<FieldDefinition> entityFieldDefs = entityFieldMap.get(field.EntityDefinitionId);
            if (entityFieldDefs == null) entityFieldDefs = new List<FieldDefinition>();
            entityFieldDefs.add(field);
            entityFieldMap.put(field.EntityDefinitionId, entityFieldDefs);            
        }
        
		// update map keys from Entity.Id to Entity.QualifiedApiName
		Map<String, List<FieldDefinition>> entityFieldMap2 = new Map<String, List<FieldDefinition>>();
        for (String key : entityFieldMap.keySet()) {
            //System.debug('> key: ' + key);
            List<FieldDefinition> entityFieldDefs = entityFieldMap.get(key);
            EntityDefinition entity = entities.get(key);
            //System.debug('> qualifiedApiName: ' + entity.QualifiedApiName);
            entityFieldMap2.put(entity.QualifiedApiName, entityFieldDefs);
        }
        
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - entityFieldMap: ' + entityFieldMap2.size());
        for (String key : entityFieldMap2.keySet()) {
            System.debug('RC_DataMaskCompliance > getEntityFieldMap > compliance fields for object: ' + key);
            List<FieldDefinition> entityFieldDefs = entityFieldMap2.get(key);           
            for (FieldDefinition field : entityFieldDefs) {
                System.debug('RC_DataMaskCompliance > getEntityFieldMap >> ' + field);
            }
        }
        
        System.debug('RC_DataMaskCompliance > getEntityFieldMap - complete');        
        return entityFieldMap2;
                     
    } // end getEntityFieldMap

	static public void clearLatestFlagOnLastReport() {
        System.debug('RC_DataMaskCompliance > clearLatestFlagOnLastReport - start');  
        List<RC_DM_Compliance_Field__c> reportEntries = [SELECT Id FROM RC_DM_Compliance_Field__c WHERE Latest_Report__c = true];
        for (RC_DM_Compliance_Field__c entry : reportEntries) {
            entry.Latest_Report__c = false;
        }
        update reportEntries;
        System.debug('RC_DataMaskCompliance > clearLatestFlagOnLastReport - complete');  
    }
    
    static public void deleteAllComplianceReports() {
        List<RC_DM_Compliance_Field__c> entries = [SELECT Id FROM RC_DM_Compliance_Field__c];
        if (entries.size() > 0) {
			delete entries;
            System.debug('RC_DataMaskCompliance > deleteAllComplianceReports - deleted ' + entries.size() + ' report entries');  
    	}
    }
    
    static public void deleteComplianceReports(List<String> reportIDs) {
        System.debug('RC_DataMaskCompliance > deleteComplianceReports - reportIDs: ' + reportIDs);
        List<RC_DM_Compliance_Field__c> entries = [SELECT Id FROM RC_DM_Compliance_Field__c WHERE Report_ID__c IN :reportIDs];
        if (entries.size() > 0) {
			delete entries;
            System.debug('RC_DataMaskCompliance > deleteComplianceReports - deleted ' + entries.size() + ' report entries');  
    	}
    }
    
} // end RC_DataMaskCompliance