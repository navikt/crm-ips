import { LightningElement,track,wire} from 'lwc';
import Id from '@salesforce/user/Id';
import getUserActivity from '@salesforce/apex/IPS_myActivityController.getUserActivity';

const COLUMNS = [
    {label:'Dato',fieldName: 'ActivityDate',type: 'date', hideDefaultActions: true},
    {label:'Emne',fieldName: 'Subject',type: 'text', hideDefaultActions: true}
];

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myWeekActivities extends LightningElement {
@track userActivity;
columns = COLUMNS;
currentUser = Id;
isWeekly = true;
isData = false;
error;

    /* activty logo */
    myActivityImg = IPS_HOME_LOGOS + '/CupFilled.svg';

@wire(getUserActivity,{userId: '$currentUser',weekly:'$isWeekly'})
activityList(result){
    if(result.data){
        if(result.data.length >0){
            this.userActivity = result.data;
            this.isData = true;
        }
        this.error = undefined;
    }else if(result.error){
        console.error(error);
        this.error = error;
    }
}   
}

