
		String optyRecordType = 'PARENT_OPPORTUNITY_RECORD_TYPE';
		Map<String, Map<String, Map<String, String>>> mapStageDependentRequiredFields = new Map<String, Map<String, Map<String, String>>>();    
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'OpportunityChildObjectRequiredFieldsMapping' LIMIT 1];
        String fileContent = sr.Body.toString();
    
        Map<String, Object> mapOptyRecordType = (Map<String, Object>)JSON.deserializeUntyped(fileContent);
		Map<String, Object> mapStages = (Map<String, Object>) mapOptyRecordType.get(optyRecordType);
		Map<String, Map<String, String>> mapRequiredFieldsConverted = new Map<String, Map<String, String>>();
		for(String stageName:mapStages.keySet()){
				Map<String, Object> mapStageDependentRequiredFields = (Map<String, Object>) mapStages.get(stageName);
            	for(String fieldName:mapStageDependentRequiredFields.keySet()){
					Map<String, Object> mapFieldAttribs = (Map<String, Object>)mapStageDependentRequiredFields.get(fieldName);
                    Map<String, String> mapFieldValues = new Map<String, String>();
                    for(String fieldAttr:mapFieldAttribs.keySet()){
                        mapFieldValues.put(fieldAttr, (String)mapFieldAttribs.get(fieldAttr));
                    }
                    mapRequiredFieldsConverted.put(fieldName, mapFieldValues);
                }//for
            	mapStageDependentRequiredFields.put(milestone, mapRequiredFieldsConverted);
		}//for

		Map<String, LOV__mdt> mapMAOrder = new Map<String, LOV__mdt>([SELECT Id, MasterLabel, High__c, Text1__c, Text2__c FROM LOV__mdt  WHERE Type__c = 'OPTY_STAGE_ORDER' and Text1__c = 'PARENT_OPPORTUNITY_RECORD_TYPE' order by High__c]);
        List<Opportunity> lstOpportunities = [SELECT Id, StageName FROM Opportunity];
        for(Opportunity opty: lstOpportunities){
            //loop through Stage values in ascending order, and set it on Opportunity
            for(LOV__mdt mdt: mapMAOrder.values()){
                opty.StageName = mdt.Text2__c;
                Map<String, Map<String, String>> mapStageDependentRequiredFields = mapStageDependentRequiredFields.get(opty.StageName);
                if(mapStageDependentRequiredFields != null){
                    for(String fieldName: mapStageDependentRequiredFields.keySet()){
                        Map<String, String> fieldAttribs = mapStageDependentRequiredFields.get(fieldName);
                        String dataType = fieldAttribs.get('dataType');
                        String fieldValue = fieldAttribs.get('fieldValue');
                        switch on dataType {
                            when 'DATE'{
                                switch on fieldValue {
                                    when  'TODAY'{
                                        opty.put(fieldName, System.today());
                                    }
                                    when 'TOMORROW' {
                                        opty.put(fieldName, System.today()+1);
                                    }
                                    when 'NEXT_WEEK' {
                                        opty.put(fieldName, System.today()+7);
                                    }
                                    when 'NEXT_MONTH' {
                                        opty.put(fieldName, System.today()+30);
                                    }
                                    when else{
                                        //standard date format “yyyy-MM-dd HH:mm:ss” in the local time zone.
                                        Date dateval = Date.valueOf(fieldValue);
                                        opty.put(fieldName, dateval);
                                    } 
                                }//switch-DATE-fieldValue      
                            }//DATE
                            when 'DATETIME'{
                                switch on fieldValue {
                                    when  'NOW'{
                                        opty.put(fieldName, System.now());
                                    }
                                    when 'TOMORROW' {
                                        opty.put(fieldName, (System.now()).addDays(1));
                                    }
                                    when 'NEXT_WEEK' {
                                        opty.put(fieldName, (System.now()).addDays(7));
                                    }
                                    when 'NEXT_MONTH' {
                                        opty.put(fieldName, (System.now()).addDays(30));
                                    }
                                    when else{
                                        //standard date format “yyyy-MM-dd HH:mm:ss” in the local time zone.
                                        Datetime datetimeval = Datetime.valueOf(fieldValue);
                                        opty.put(fieldName, datetimeval);
                                    } 
                                }//switch-DATETIME-fieldValue                                  
                            }//DATETIME
                            when 'INTEGER'{
                                opty.put(fieldName, Integer.valueOf(fieldValue));
                            }
                            when 'DECIMAL'{
                                opty.put(fieldName, Decimal.valueOf(fieldValue));
                            }//DECIMAL
                            when 'BOOLEAN'{
                                //Boolean b = Boolean.valueOf('true');
                                opty.put(fieldName, Boolean.valueOf(fieldValue));
                            }//BOOLEAN
                            when else{
                                //String
                                opty.put(fieldName, fieldValue);
                            }                                    
                        }//switch-dataType
                    }//for
                }//if                
                update opty;
            }//for
        }//for
		
/*
Static Resource: OpportunityChildObjectRequiredFieldsMapping.json

{  
	"OptyRecType-UpSale" : {
		"Stage-01" : {
		"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		}
  },
	"OptyRecType-CrossSale" : {
		"Stage-01" : {
		"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		}
  },
	"OptyRecType-EmergingMarket" : {
		"Stage-01" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									},
			"SignUp_Date__c" : {
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		},
		"Stage-02" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									},
			"Count__c" : {
										"fieldValue" : "1",
										"dataType" : "INTEGER"
									}
		},
		"Stage-03" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		},
		"Stage-04" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		},
		"Stage-05" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		},
		"Stage-06" : {
			"SignUp_Date__c"	:	{
										"fieldValue" : "TODAY",
										"dataType" : "DATE"
									}
		}
  }						
}
		
*/
