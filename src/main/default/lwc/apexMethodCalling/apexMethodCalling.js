import { LightningElement, wire } from 'lwc';
import getAccountLst from '@salesforce/ApexMethodCalling.getAccountLst'

export default class ApexMethodCalling extends LightningElement {

    @wire(getAccountLst)
    accounts;

    get responseReturnVal(){
        if(this.accounts){
            return true;
        }

            return false;
    }
}