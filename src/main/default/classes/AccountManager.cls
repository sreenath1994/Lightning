public with sharing class AccountManager {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        return [SELECT id, Name, Phone FROM Accounr LIMIT 10];
    }
    
}
