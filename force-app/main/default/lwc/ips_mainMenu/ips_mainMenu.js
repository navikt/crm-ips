import { LightningElement,api,wire,track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getUserWorkTrail from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';
import { NavigationMixin } from 'lightning/navigation';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';


export default class Ips_mainMenu extends NavigationMixin(LightningElement) {
    userIds = USER_ID;
    //userIds = '0051X00000DAHjSQAX';
    @api recordId;
    @track record;
    isIPS = false;
    recordTypeName;
    isIPSTrue = false;

    /* profile logo */
    myProfileImg = IPS_HOME_LOGOS + '/ProfileFilled.svg';
    myActivityImg = IPS_HOME_LOGOS + '/CalenderFilled.svg';
    myGoalImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
    privacyImg = IPS_HOME_LOGOS + '/LawFilled.svg';
    extLinkImg = IPS_HOME_LOGOS + '/ExternalLinkFilled.svg';
    myWorkProfile = IPS_HOME_LOGOS + '/EmployerFilled.svg';

    

    @wire(getUserWorkTrail,{userId:'$userIds'})
    wiredTrail({error,data}){
        console.log('Dette er data fra wire: '+JSON.stringify(data));
            if(data){
                this.record = data[0];
                this.recordTypeName = this.record.RecordType?.DeveloperName;
                if(this.recordTypeName ==='IPS'){
                    this.isIPSTrue = true;
                }
            }else if(error){
                console.log('Something went wrong: '+error);
            }
    }
    
     get trailId(){
            return this.record?.Id;
     }

     get recordTypeId(){
        return this.record?.RecordTypeId;

     }
/*
     get recordTypeName(){
        return this.record.RecordType?.DeveloperName;
     }*/
   
}