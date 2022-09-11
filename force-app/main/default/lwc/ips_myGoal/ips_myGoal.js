import { LightningElement,wire,api} from 'lwc';
import getUserGoal from '@salesforce/apex/IPS_myWorkTrailController.getUserGoal';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myGoal extends LightningElement {
    /* profile logo */
    myGoalImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
    @api recordId;
    wiredRequestResult;
    mainGoal;
    isData = false;

    @wire(getUserGoal)
    async wiredRequest(result){
        this.wiredRequestResult = result;
        if(result.data){
            this.wiredRequestResult = result.data;
            this.mainGoal = this.wiredRequestResult.fields.ips_Main_goal__c.value;
            this.error = undefined;
            this.isData = true;
        }else if(result.error) {
            this.error = result.error;
        }
    } 
}