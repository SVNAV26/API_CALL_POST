global class CloseCasesInWorkForce implements Database.Batchable<sObject>, Database.AllowsCallouts {
    /**
        * .
        *
        * @category  
        * @author    Subbiah Kumar
	*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String value = 'closed';
        String query = 'SELECT Id FROM Case where Secret_Key__c = NULL AND Status =\''+String.escapeSingleQuotes(value)+'\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
       
        // process each batch of records

        list<Case> csListToBeUpdated = new List<Case>();
        for(Case cs : caseList) {        
            try{
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                
                    request.setHeader('Content-Type', 'application/json');
                    request.setEndpoint('Your Endpoint URL');
                    request.setMethod('POST');
                	request.setBody('{"id":"'+cs.Id+'", '+'"agentId:"'+cs.OwnerId+'" }');
                    response = http.send(request);
                    if (response.getStatusCode() == 200) {
                        String jsonResponse = response.getBody();
                        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
                        System.debug('secret key from Workforce -' + result.get('secretKey'));
                        cs.Secret_Key__c = String.valueOf(result.get('secretKey'));
                        csListToBeUpdated.add(cs);
                    }
                	if (response.getStatusCode() == 500) {
                        String jsonResponse = response.getBody();
                        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
                        System.debug('Error in callout -' + result.get('error'));
                        
                        //For Failed Cases, it can be saved back into a log object to get track of failed records(Just for record purpose)
                        //Otherwise there is no additional need, this class will take care of the failed cases in next callout
                    }
                }
                catch(Exception e){
                    System.debug('Error-' + e.getMessage());   
                }
        }
        try {
        	// Update the Case Record
            if(!csListToBeUpdated.isEmpty()){
                update csListToBeUpdated;
            }
        
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}