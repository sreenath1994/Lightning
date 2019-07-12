global with sharing class BatchApexDemo implements Database.Batchable<SObject>{

    global Database.Database.QueryLocator start(Database.BatchableContext bc){
        
    }
    global void execute(Database.BatchableContext bc, List<P> records){
        // process each batch of records
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
}

