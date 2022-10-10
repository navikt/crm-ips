import { LightningElement,api,wire,track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getUserWorkTrail from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';
import { NavigationMixin } from 'lightning/navigation';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';


export default class Ips_mainMenu extends NavigationMixin(LightningElement) {
    //@track userIds = '0051X00000DAHjSQAX';
    @track userIds = USER_ID;
    @api recordId;
    @track record;
    isIPS = false;
    recordTypeName;
    isIPSTrue = false;
    isUOTrue = false;

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
                        this.isUOTrue = false;
                    }
                    if(this.recordTypeName ==='ips_Supported_Employment'){
                        this.isUOTrue = true;
                        this.isIPSTrue = false;
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
   
}