
import { LightningElement,wire,api,track} from 'lwc';
import USER_ID from '@salesforce/user/Id';
//import getUserGoal from '@salesforce/apex/IPS_myWorkTrailController.getUserGoal';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myGoal extends LightningElement {
    /* profile logo */
    myGoalImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
    @api recordId;
    userIds = USER_ID;

   /* @wire(getUserGoal,{userId:'$userIds'})
    userGoal*/
}
