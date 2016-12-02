/** to run batch job ..
string query = 'select Id, SSO_Count__c from Timeline_Event__c';
SingleServiceOfferBatchProcess ssoBatch = new SingleServiceOfferBatchProcess(query);
Database.executeBatch(ssoBatch);


This class is tested for coverage in the SingleServiceOfferTriggerHelperTest class.

**/

global class SingleServiceOfferBatchProcess implements Database.Batchable<sObject>{

    global final string query;
    global final list<string> idList;

    //constructor
    global SingleServiceOfferBatchProcess (String q) {
        query = q;   
    }

    //constructor
    global SingleServiceOfferBatchProcess (String q, list<string> qlist ) {
        idList = qlist;
        query = q + ' where id in :idList';   
    }
        
     
    //start
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
     
     
    //execute
    global void execute(Database.BatchableContext BC, List<Timeline_Event__c> scope) {
//system.debug(' @@@@@@@@@@@@@@@@@   scope ..   ' + scope);
        SingleServiceOfferTriggerHelper.updateAllSSOCounters(scope);
    
    }
  
  
 //finish
    global void finish(Database.BatchableContext BC) {

        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
       
       // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Process to update all Timeline Event SSO Counts ' + a.Status);
        mail.setPlainTextBody

        ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
    
    
    }    
    
}