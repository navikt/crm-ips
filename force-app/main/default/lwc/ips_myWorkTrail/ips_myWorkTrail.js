import { LightningElement,wire,api} from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getUserWorkTrail from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myWorkTrail extends LightningElement {
/* profile logo */
myGoalImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
@api recordId;
userIds = USER_ID;

@wire(getUserWorkTrail,{userId:'$userIds'})
    userTrail
}