public with sharing class AttachmentChangeTriggerHandler {

    public static void attachmentChange(map<Id, Attachment> attachmentMap){
        
        try{
            set<Id> sibAccommodationList = new set<Id> ();          
            set<Id> sibEmploymentList = new set<Id> ();
            set<Id> sibQualificationsList = new set<Id> ();         
            set<Id> sibReconnectionsList = new set<Id> ();
            set<Id> sibSelfEmploymentList = new set<Id> ();

            //Loop through attachment map and populate relevant set with id of parent object
            for(Attachment att : attachmentMap.values()){  
                if(att.ParentId.getSobjectType() == SIB_Verification_Accommodation__c.SobjectType){
                    sibAccommodationList.add(att.ParentId); 
                }   

                if(att.ParentId.getSobjectType() == SIB_Verification_Employment__c.SobjectType){
                    sibEmploymentList.add(att.ParentId);    
                } 

                if(att.ParentId.getSobjectType() == SIB_Verification_Qualifications__c.SobjectType){
                    sibQualificationsList.add(att.ParentId);    
                } 
                
                if(att.ParentId.getSobjectType() == SIB_Verification_Reconnections__c.SobjectType){
                    sibReconnectionsList.add(att.ParentId); 
                } 
                
                if(att.ParentId.getSobjectType() == SIB_Verification_Self_emp_Vol__c.SobjectType){
                    sibSelfEmploymentList.add(att.ParentId);    
                }               
             }
             
             // Check whether object id set is populated and attachment flag should therefore be verified
             if (sibAccommodationList.size() > 0){
                verifyAttachmentFlag(new List<Id>(sibAccommodationList));   
             }

             if (sibEmploymentList.size() > 0){
                verifyAttachmentFlag(new List<Id>(sibEmploymentList));  
             }             

             if (sibQualificationsList.size() > 0){
                verifyAttachmentFlag(new List<Id>(sibQualificationsList));  
             }             

             if (sibReconnectionsList.size() > 0){
                verifyAttachmentFlag(new List<Id>(sibReconnectionsList));   
             }

             if (sibSelfEmploymentList.size() > 0){
                verifyAttachmentFlag(new List<Id>(sibSelfEmploymentList));  
             }                          
                        
            
        } catch (exception e){
            system.debug( 'ERROR.... ERROR.... ERROR....' + e.getMessage() + ' : ' + e.getStackTraceString());            
        }
    }   

    // This method checks the attachments for the object ids passed in
    // and updates the attachment flag to indicate whether the object has an 
    // attachment or not.
    private static void verifyAttachmentFlag(list<ID> idList){
        
        string sobjectName = '';
        string soql = '';
        list<Sobject> updateList = new list<Sobject>();
        
        if (idList != null){
            
            if (idList.size() > 0){
               // Get the sObject token from the first ID
                //(the List contains IDs of sObjects of the same type).
                Schema.SObjectType token = idList[0].getSObjectType();
                
                // Using the token, do a describe 
                // and construct a query dynamically. 
                Schema.DescribeSObjectResult dr = token.getDescribe();
                String queryString = 'SELECT name, Attachments__c, (Select Id, name from Attachments)  FROM ' + dr.getName() + 
                    ' WHERE ';
                for(ID objId : idList) {
                    queryString += 'Id=\'' + objId + '\' OR ';
                }    
                // Remove the last ' OR'
                queryString = queryString.subString(0, queryString.length() - 4);
                system.debug('######   Running query .. ' + queryString); 
                updateList = Database.query(queryString);

                for (sobject obj :updatelist){
                    list<Sobject> attachmentList = obj.getSobjects('Attachments');
                    integer attachmentCount = 0;
                    if (attachmentList != null){
                        attachmentCount = attachmentList.size();
                        obj.put('Attachments__c', true);
                    } else {
                        obj.put('Attachments__c', false);
                    }
                    system.debug('######   ' + obj.get('id') + ' -- '+ attachmentCount);                    
                }

                if (updateList.size() > 0){
                    Database.SaveResult[] srList = Database.update(updateList, false);
                    for(Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug('Updated Attachments__c field successfully for ' + 
                                dr.getName() + ' ID ' + sr.getId());
                        }
                        else {
                            System.debug('Updating ' + dr.getName() + ' returned the following errors.');
                            for(Database.Error e : sr.getErrors()) {
                                System.debug(e.getMessage());
                            }
                        }
                    }
                }

            }

        }       
        
    }       
        
    public static void updateAllAttachmentFlags(){
    
        try{
            
            list<Id> idList = new list<Id>();
            
            list<SIB_Verification_Accommodation__c> sibList1 = [select id from SIB_Verification_Accommodation__c];
            idList = new list<Id>();
            for (SIB_Verification_Accommodation__c a :sibList1){
                idList.add(a.Id);       
            }    
            verifyAttachmentFlag(idList);        

            list<SIB_Verification_Employment__c> sibList2 = [select id from SIB_Verification_Employment__c];
            idList = new list<Id>();
            for (SIB_Verification_Employment__c a :sibList2){
                idList.add(a.Id);       
            }    
            verifyAttachmentFlag(idList);         

            list<SIB_Verification_Qualifications__c> sibList3 = [select id from SIB_Verification_Qualifications__c];
            idList = new list<Id>();
            for (SIB_Verification_Qualifications__c a :sibList3){
                idList.add(a.Id);       
            }    
            verifyAttachmentFlag(idList); 
       
            list<SIB_Verification_Reconnections__c> sibList4 = [select id from SIB_Verification_Reconnections__c];
            idList = new list<Id>();
            for (SIB_Verification_Reconnections__c a :sibList4){
                idList.add(a.Id);       
            }    
            verifyAttachmentFlag(idList); 

            list<SIB_Verification_Self_emp_Vol__c> sibList5 = [select id from SIB_Verification_Self_emp_Vol__c];
            idList = new list<Id>();
            for (SIB_Verification_Self_emp_Vol__c a :sibList5){
                idList.add(a.Id);       
            }    
            verifyAttachmentFlag(idList); 

        
        } catch (exception e){
            system.debug( 'ERROR.... ERROR.... ERROR....' + e.getMessage() + ' : ' + e.getStackTraceString());        
        }
    
    
    
    }    

    

}