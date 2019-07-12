/**************************************************************************************************
*** Class Name             : ShipNowController
*** Class Description      : Stores and Retrieves the source address labels & values from Custom 
							 Object and also fetches the fedex charges from the Fedex API
*** Author                 : Coreflex Solutions
*** Class Created Date     : 4/15/2019
*** Configurable Parameters:
*        End Point URL     :
*        Custom Labels Used:
*        Custom Object Used: Label - Source Address & API Name - Source_Address__c 
*** Change Management      :
*        Change #          : 
*        Change Description:
*        Modified Date     :
*        Modified By       :
**************************************************************************************************/

public with sharing class ShipNowController {
    
    public static string defaultSrcAddrLabel; 
    
    public ShipNowController(){
        
          list<Opportunity_Field_Mapping__c> getOpptnyFieldValues =[select id,name,City__c,Country__c,Phone__c,Postal_Code__c,Street__c,State__c from Opportunity_Field_Mapping__c];
       
        for(Opportunity_Field_Mapping__c oppFieldMaps : getOpptnyFieldValues){
            Opportunity opport= new Opportunity();
            opport.Name='Test';
            opport.ShippingStreet__c=oppFieldMaps.Street__c;
            opport.StageName ='Prospecting';
            opport.CloseDate = system.today();
            opport.ShippingState__c=oppFieldMaps.State__c;
            opport.ShippingPostalCode__c=oppFieldMaps.Postal_Code__c;
            opport.ShippingCountry__c=oppFieldMaps.Phone__c;
            opport.ShippingCity__c=oppFieldMaps.City__c;
            opport.Phone_Number__c=oppFieldMaps.Phone__c; 
            insert opport;
        }
      
    }
    
    /**************************************************************************************************
*** Method Name             : fedExCharges
*** Method Description      : Get the response from FedEx API and displaying shipping charges.
**************************************************************************************************/
    
    @AuraEnabled
    public static Map<String,Decimal> fedExCharges( ) 
    {
        map<string,Decimal> shipValue= new map<string,Decimal>();
        String[] charges =  new List<String>();
        Map<String,String> Fedex = new Map<String,String>();
        shipValue = InvokeFedexRateService.invokeFedex();
        return shipValue;
        
    }
    
    /*************************************************************************************************************************
*** Method Name             : getselectedSourceAddrValue
*** Method Description      : Returns the source Address details based on selected Source Address label in Shipnow component 
******************************************************************************************************************************/
    @AuraEnabled
    public static List<String> getselectedSourceAddrValue(string sourceAddrLabel){
        List<Source_Address__c> sourceAddrValue = [select Street__c, City__c, State__c, Zip__c, Country__c from Source_Address__c where Title__c=: sourceAddrLabel];
        List<String> sourceAddrValues = new List<String>();
        for (Source_Address__c sourceAddrVal : sourceAddrValue){
            sourceAddrValues.add(sourceAddrVal.Street__c);
            sourceAddrValues.add(sourceAddrVal.City__c);
            sourceAddrValues.add(sourceAddrVal.State__c);
            sourceAddrValues.add(sourceAddrVal.Country__c);
            sourceAddrValues.add(string.valueOf(sourceAddrVal.Zip__c));
        }
        
        return sourceAddrValues;
    }
    
    /*****************************************************************************************************************
*** Method Name             : getSourceAddrLabels
*** Method Description      : Returns the source Address Labels which are stored in 'Source_Address__c' custom object
*************************************************************************************************************************/
    @AuraEnabled
    public static List<string> getSourceAddrLabels(){
        List<Source_Address__c> sourceAddrLabels = [select id,Title__c from Source_Address__c ];
        list<String> sourceAddrLabelslist = new list<String>();
        for(Source_Address__c sourceAddrlabel : sourceAddrLabels){
            sourceAddrLabelslist.add(sourceAddrlabel.Title__c);
        }
        
        return sourceAddrLabelslist;
    }
    
    /*********************************************************************************************************************************
*** Method Name             : getDefaultSourceAddrLabel
*** Method Description      : Returns the default source Address label, which have been set at configuration page in Shipnow component 
****************************************************************************************************************************************/
    @AuraEnabled
    public static String getDefaultSourceAddrLabel(){
        List<Source_Address__c> sourceAddrList = [select Title__c,default__c from Source_Address__c];
        if(sourceAddrList.size() != 0){
            
            
            List<Source_Address__c> sourceAddrLabels = [select Title__c,default__c from Source_Address__c where default__c =true];
            
            list<String> defaultSourceAddrLabelsList = new list<String>();
            for(Source_Address__c sourceAddrlabel : sourceAddrLabels){
                defaultSourceAddrLabelslist.add(sourceAddrlabel.Title__c);
            }
            system.debug('sourceAddrLabels'+defaultSourceAddrLabelslist);
            
            
            return defaultSourceAddrLabelslist[0];
        }
        return '';
    }
    
    /*****************************************************************************************************************************
*** Method Name             : getDefaultSourceAddrValue
*** Method Description      : Returns the default source Address details based on default Source Address label in Shipnow component 
************************************************************************************************************************************/ 
    @AuraEnabled
    public static List<String> getDefaultSourceAddrValue(){
        defaultSrcAddrLabel = getDefaultSourceAddrLabel();
        system.debug('defaultSrcAddrLabel ' + defaultSrcAddrLabel);
        List<Source_Address__c> sourceAddrValue = [select Street__c,City__c,State__c,Zip__c,Country__c from Source_Address__c where Title__c =: defaultSrcAddrLabel];
        List<String> defaultSourceAddrValues = new List<String>();
        for (Source_Address__c sourceAddrVal : sourceAddrValue){
            defaultSourceAddrValues.add(sourceAddrVal.Street__c);
            defaultSourceAddrValues.add(sourceAddrVal.City__c);
            defaultSourceAddrValues.add(sourceAddrVal.State__c);
            defaultSourceAddrValues.add(sourceAddrVal.Country__c);
            defaultSourceAddrValues.add(string.valueOf(sourceAddrVal.Zip__c));
        }
        
        return defaultSourceAddrValues;
    }
    
    
    /*****************************************************************************************************************************
*** Method Name             : addressPage
*** Method Description      :  
************************************************************************************************************************************/ 
    
    @AuraEnabled
    public static void addressPage(String sourceRecord,String streetAddress,string city,String state,String country,String zipCode,String phNumber){
        InvokeFedexRateService.addressInformation(sourceRecord,streetAddress,city,state,country,zipCode,phNumber);
    }
    
    /*****************************************************************************************************************************
*** Method Name             : shipInfoButton
*** Method Description      :  
************************************************************************************************************************************/ 
    
    
    @AuraEnabled
    public static void shipInfoButton(Date shipDate, integer packge, Decimal weight, string packageType, string declaredValue,string weightUnits){
        InvokeFedexRateService.shippingInfo(shipDate,packge,weight,packageType,declaredValue,weightUnits);
    }
    
    /**************************************************************************************************
*** Method Name             : getRecordId
*** Method Description      : Returns the first three digits of the Order or Opportunity record id
**************************************************************************************************/
    
    @AuraEnabled
    public static String getRecordId(string orderOrOppId){
        String firstFourDigits = orderOrOppId.substring(0, 3);
        return firstFourDigits;
        
    }
    
    /**************************************************************************************************
*** Method Name             : insertAndUpdateData
*** Method Description      : Saving the Source Address to Custom Object from configuration page
**************************************************************************************************/
    
    @AuraEnabled
    public static void insertOrUpdateData(string title, string street, string city, string state, Decimal zipcode, string country, String phoneNo, string company, string contactName,boolean defaultValue,string srcId){
        list<Source_Address__c> srcAddrs=new list<Source_Address__c>();
        list<Source_Address__c> updateSrcAddr=new list<Source_Address__c>();
        list<Source_Address__c> defaultSrcAddr =[select id, Default__c from Source_Address__c];
        if(srcId == null){
            Source_Address__c insertSrcAddress = new Source_Address__c(Title__c = title, City__c = city, Country__c = country, Phone_Number__c = string.valueOf(phoneNo), State__c = state, Street__c = street, Zip__c = string.valueOf(zipcode), Default__c = defaultValue);
            if(insertSrcAddress.Default__c == TRUE){
                for(Source_Address__c srcAddr :defaultSrcAddr){
                    if(srcAddr.Default__c == true){
                        srcAddr.Default__c=false;
                        updateSrcAddr.add(srcAddr);
                        
                    }
                }
                update updateSrcAddr;
            }
            if(insertSrcAddress.Title__c != null || insertSrcAddress.State__c != null || insertSrcAddress.Street__c != null || insertSrcAddress.City__c != null)
                srcAddrs.add(insertSrcAddress);
            	insert srcAddrs;
        }
        else{
            list<Source_Address__c> editedSrcAddress = [select id,Title__c, City__c,Default__c, Country__c, State__c, Street__c, Zip__c, Phone_Number__c from Source_Address__c where id=:srcId];
            for(Source_Address__c editSrcAddress :editedSrcAddress){
                editSrcAddress.Title__c =title;
                editSrcAddress.City__c =city;
                editSrcAddress.Default__c=defaultValue;
                editSrcAddress.Country__c=country;
                editSrcAddress.State__c=state;
                editSrcAddress.Street__c=street;
                editSrcAddress.Zip__c=string.valueof(zipcode);
                editSrcAddress.Phone_Number__c=phoneNo;
                srcAddrs.add(editSrcAddress);
            }
            if(srcAddrs[0].Default__c == true){
                for(Source_Address__c defaultSrcAddess : defaultSrcAddr){
                    if(defaultSrcAddess .Default__c == true){
                        defaultSrcAddess.Default__c =false;
                        updateSrcAddr.add(defaultSrcAddess);
                    }
                    
                }
                
                update updateSrcAddr;
            }
            update srcAddrs;
        }
        
    }
    
    
    /**************************************************************************************************
*** Method Name             : srcAddrGetData
*** Method Description      : Getting the data from source address custom object and displaying on configuration page.
**************************************************************************************************/
    
    @AuraEnabled
    public static  list<Source_Address__c> srcAddrGetData(){
        list<Source_Address__c> srcAddress= [select id,Title__c, City__c,Default__c, Country__c, State__c, Street__c, Zip__c, Phone_Number__c from Source_Address__c];        
        
        return srcAddress;
    }
    
    
    /*************************************************************************************************************************
*** Method Name             : deleteSourceAddr
*** Method Description      : Deleting the data from source address custom object which is displaying on configuration page.
*****************************************************************************************************************************/
    
    @AuraEnabled
    public static Source_Address__c deleteSourceAddr(String sourceAddrRecId){
        list<Source_Address__c> srcAddresses =[select id from Source_Address__c];
        Source_Address__c sourceAddrRec = [select id, Title__c,Default__c from Source_Address__c where id =: sourceAddrRecId];
        if(sourceAddrRec.Default__c != true){
            
            delete sourceAddrRec;
        }
        return sourceAddrRec;
    }
    
    /**************************************************************************************************************************
*** Method Name             : updateSrcAddress
*** Method Description      : Updating the data from source address to custom object which is displaying on configuration page.
********************************************************************************************************************************/
    
    @AuraEnabled
    public static list<Source_Address__c> updateSrcAddress(String recId ,boolean defaults){
        list<Source_Address__c> srcAddress = new list<Source_Address__c>();
        list<Source_Address__c> sourceAddress =[select id,Default__c from Source_Address__c where (id =:recId OR Default__c = True)];
        if(defaults == True){
            for(Source_Address__c srcAddr : sourceAddress){
                if(srcAddr.Default__c == true){
                    srcAddr.Default__c = false;
                }else{
                    srcAddr.Default__c = true; 
                }
                srcAddress.add(srcAddr);
            }
            update srcAddress;
            
        }
        return srcAddress;
        
    } 
    
    
    /**************************************************************************************************
*** Method Name             : courierCompany
*** Method Description      : This method will store the selected courier company into the custom settings
**************************************************************************************************/
    
    @AuraEnabled
    public static void courierCompany(boolean FedEx,boolean Ups,boolean Dhl){
        list<SelectedCompany__c> selCmpny =[select id from SelectedCompany__c];   
        delete selCmpny;
        List<SelectedCompany__c> selCompanyList = new  List<SelectedCompany__c>();
        if(FedEx == true){
            SelectedCompany__c selCompany = new SelectedCompany__c();
            selCompany.Name='FedEx';
            selCompany.Company__c=FedEx;
            selCompanyList.add(selCompany);
        }
        if(Ups == true){
            SelectedCompany__c selCompany = new SelectedCompany__c();
            selCompany.Name='Ups';
            selCompany.Company__c=Ups;
            selCompanyList.add(selCompany);
            
        }
        if(Dhl == true){
            SelectedCompany__c selCompany = new SelectedCompany__c();
            selCompany.Name='Dhl';
            selCompany.Company__c=Dhl;
            selCompanyList.add(selCompany);
            
        }
        if(selCompanyList.size()>0)
            insert selCompanyList;
       
    }
    
    /**************************************************************************************************
*** Method Name             : selectedCourier
*** Method Description      : Returns the list of courier names which has been set at configuration level
**********************************************************************************************************/
  
    @AuraEnabled
    public static List<String> selectedCourier(){
         list<SelectedCompany__c> listOfCouriers = [select name, Company__c from SelectedCompany__c];
         List<string> courierCompanyList = new List<string>();
        for(SelectedCompany__c courierName : listOfCouriers){
            courierCompanyList.add(courierName.name);
        }
        return courierCompanyList;
    }
    
    /**************************************************************************************************
*** Method Name             : editSrcAddress
*** Method Description      : Gets the record id and auto populates the field values into the edit form
**********************************************************************************************************/
    
    
    @AuraEnabled
    public static Source_Address__c editSrcAddress(string editRecId){
        Source_Address__c srcAdrss =[select id,Title__c, City__c,Default__c, Country__c, State__c, Street__c, Zip__c, Phone_Number__c from Source_Address__c where id =:editRecId];
        return srcAdrss;
    }
    
     /**************************************************************************************************
*** Method Name             : opportunityFields
*** Method Description      : Gets the opportunity fields and display as a picklist values
**********************************************************************************************************/
    @AuraEnabled
    public static list<string> opportunityFields(){
        Schema.DescribeSObjectResult oppFields = opportunity.sObjectType.getDescribe();
        List<String> apiNames = new list<String>();
        List<String> fieldAPIName = new list<String>();
        for(string apiName : oppFields.fields.getMap().keySet()){
            apiNames.add(apiName);
            
        }
        return apiNames;
    }
    
     /**************************************************************************************************
*** Method Name             : orderFields
*** Method Description      : Gets the order fields and display as a picklist values
**********************************************************************************************************/
    @AuraEnabled
    public static list<string> orderFields(){
        Schema.DescribeSObjectResult ordFields = order.sObjectType.getDescribe();
        List<String> apiNames = new list<String>();
        List<String> fieldAPIName = new list<String>();
        for(string apiName : ordFields.fields.getMap().keySet()){
            apiNames.add(apiName);
            
        }
        return apiNames;
    }
    
    /**************************************************************************************************
*** Method Name             : fieldsMapping
*** Method Description      : Gets the selected mapping fields and store into custom settings
**********************************************************************************************************/
    
    @AuraEnabled
    public static void fieldsMapping(string street,string state,string city,string country,string phone,String postalCode){
      
        list<Opportunity_Field_Mapping__c> delOpptyFieldMapping =[select id  from Opportunity_Field_Mapping__c];
        if(delOpptyFieldMapping.size()!=0){
            delete delOpptyFieldMapping;
        }
        Opportunity_Field_Mapping__c oppFieldMap = new Opportunity_Field_Mapping__c();
        oppFieldMap.Name = 'Opportunity Fields';
        oppFieldMap.City__c =city;
        oppFieldMap.Country__c =country;
        oppFieldMap.Phone__c =phone;
        oppFieldMap.Postal_Code__c =postalCode;
        oppFieldMap.Street__c=street;
        oppFieldMap.State__c=state;
        insert oppFieldMap;
        
    }
    /**************************************************************************************************
*** Method Name             : getSelectedCouriers
*** Method Description      : Gets the selected mapping fields and store into custom settings
**********************************************************************************************************/
    
    
  	@AuraEnabled
    public static List<String> getSelectedCouriers(){
        List<SelectedCompany__c> listOfSelectedCouriers = [select name from SelectedCompany__c];
        List<String> courierNames = new List<String>();
        for(SelectedCompany__c selectedCourier : listOfSelectedCouriers){
            courierNames.add(selectedCourier.Name);
        }
        return courierNames;
    }
    
      /**************************************************************************************************
*** Method Name             : onOpptyFieldsMapping
*** Method Description      : Gets the record id and fetch the details from opportunity object and map to 
                               our fields
**********************************************************************************************************/
    
    @AuraEnabled
    public static void onOpptyFieldsMapping(String Id){
        string custCity;
        string custCount;
        string custState;
        string custPhone;
        string custStreet;
        string custZIP;
        list<Opportunity_Field_Mapping__c> custValue= [select City__c,Phone__c,Postal_Code__c,State__c,Street__c,Country__c from Opportunity_Field_Mapping__c] ;
        if(custValue.size()!=0){
            for(Opportunity_Field_Mapping__c custValueMapping: custValue){
                custCity=custValueMapping.City__c;
                custCount=custValueMapping.Country__c;
                custState=custValueMapping.State__c;
                custPhone=custValueMapping.Phone__c;
                custStreet=custValueMapping.Street__c;
                custZIP=custValueMapping.Postal_Code__c;
            } 
            
            string dynamicQuery = 'SELECT Id ,'+custCity+','+custCount+','+custState+','+custPhone+','+custStreet+','+custZIP+' FROM Opportunity where id='+'\'' + id + '\'';
            System.debug('dynamicQuery:-'+dynamicQuery);
            List<sObject> sobjList = Database.query(dynamicQuery);
            system.debug(sobjList);
            list<opportunity> oppList = new list<opportunity>();
            opportunity oppty=new opportunity();
            for(sObject sobj : sobjList ){
                oppty.id=sobj.id;
                oppty.ShippingCity__c =sobj.get(custCity).tostring();
                oppty.ShippingStreet__c =sobj.get(custStreet).toString();
                oppty.ShippingState__c=sobj.get(custState).tostring();
                oppty.ShippingCountry__c =sobj.get(custCount).toString();
                oppty.ShippingPostalCode__c =sobj.get(custZIP).tostring();
                oppty.Phone_Number__c=sobj.get(custPhone).toString();
                
                oppList.add(oppty);
            }
            update oppList;
        }
    }
    
    /**************************************************************************************************
     * This method invokes the 'shippingRecordCreation' method in InvokeFedexRateService class, 
     * which is going to store all the shipping details into the custom object 'Shipping__C'
	***************************************************************************************************/
    @AuraEnabled
    public static void shippingRecordCreation(String orderOrOppId,string souAdd,string desStreet,string desCity,string desState,string desCoun,string desZIP,string desPhNo,date shipDt,string shipPack,string weigh,string ordAmt, string shipAmt ,string courierType){
        Shipping__c shipValue= new Shipping__c();
        InvokeFedexRateService.shippingRecordCreation(orderOrOppId,souAdd,desStreet,desCity,desState,desCoun,desZIP,desPhNo,shipDt,shipPack,weigh,ordAmt,shipAmt,courierType);
    }
    
     /**************************************************************************************************
*** Method Name             : populateSelectedCustomFields
*** Method Description      : Auto-populate/Mapping the customer address fields with Shipnow address fields
**********************************************************************************************************/
    @AuraEnabled
    public static Opportunity_Field_Mapping__c populateSelectedCustomFields(){
        Opportunity_Field_Mapping__c custSettingValue = [select id,City__c,Phone__c,Postal_Code__c,State__c,Street__c,Country__c from Opportunity_Field_Mapping__c];
       
        return custSettingValue;
    }
    
     /**************************************************************************************************
*** Method Name             : 
*** Method Description      : 
**********************************************************************************************************/
    
   @AuraEnabled
    public static void oppCurrencyFieldsMapping(String currency1, String currency2, String currency3, String currency4){
        Opportunity_Currency_Field_Mapping__c currencyFieldMap;
        if(currencyFieldMap != null){
         currencyFieldMap =[select id from Opportunity_Currency_Field_Mapping__c];
   
            delete currencyFieldMap;
        }
        
        Opportunity_Currency_Field_Mapping__c currencyFieldMapping = new Opportunity_Currency_Field_Mapping__c();
        currencyFieldMapping.Name ='Customer Currency Fields Mapping';
        currencyFieldMapping.OppCurrency1__c = currency1;
        currencyFieldMapping.OppCurrency2__c = currency2;
        currencyFieldMapping.OppCurrency3__c = currency3;
        currencyFieldMapping.OppCurrency4__c = currency4;
        system.debug('currencyFieldMapping'+currencyFieldMapping);
        insert currencyFieldMapping; 
    } 
    
    
    
    /**************************************************************************************************
*** Method Name             : 
*** Method Description      : 
**********************************************************************************************************/
    
    @AuraEnabled
    public static void ordCurrencyFieldsMapping(String currency1, String currency2, String currency3, String currency4){
        Order_Currency_Field_Mapping__c currencyFieldMap;
        if(currencyFieldMap != null){
         currencyFieldMap =[select id from Order_Currency_Field_Mapping__c];
   
            delete currencyFieldMap;
        }
        
        Order_Currency_Field_Mapping__c currencyFieldMapping = new Order_Currency_Field_Mapping__c();
        currencyFieldMapping.Name ='Customer Currency Fields Mapping';
        currencyFieldMapping.OrdCurrency1__c = currency1;
        currencyFieldMapping.OrdCurrency2__c = currency2;
        currencyFieldMapping.OrdCurrency3__c = currency3;
        currencyFieldMapping.OrdCurrency4__c = currency4;
        system.debug('currencyFieldMapping'+currencyFieldMapping);
        insert currencyFieldMapping; 
    } 
    
      /**************************************************************************************************
*** Method Name             : dhlCharges
*** Method Description      : Get the response from DHL API and displaying shipping charges.
**************************************************************************************************/
    @AuraEnabled
    public static Map<String,decimal> dhlCharges(){
        Map<String,decimal> dhlMap = new Map<String,decimal>();
      // dhlMap= InvokeDHLRateService.invokeDHLWebService();
        dhlMap.put('Express-1day', 20);
        dhlMap.put('Express-2days', 40);
        dhlMap.put('Express-3days', 60);
        dhlMap.put('Express-5days', 100);
        return dhlMap;
    }
}