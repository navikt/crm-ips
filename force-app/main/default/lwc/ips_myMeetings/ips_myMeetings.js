import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getAllActivity from '@salesforce/apex/IPS_myActivityController.getAllActivity';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myMeetings extends NavigationMixin(LightningElement) {
myMeetingImg = IPS_HOME_LOGOS + '/CalenderFilled.svg';
currentUser = Id;
//currentUser ='0053O000007R0NUQA0';
@track activityRecords;
@track record;
recordIds;
isActivity = false;

/* Fetch recordId from logged in user */
@wire(getUserWorkTrailId,{userId: '$currentUser'})
wiredtrail({ error, data }) {
        if (data) {
            this.record = data[0];
            this.recordIds = this.record?.Id;
            this.contactId = this.record?.ips_Participant__r.PersonContactId;
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    @wire(getAllActivity, {workTrailId:'$recordIds',contactId: '$contactId'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.activityRecords = data;
            this.isActivity = true;
        }
       }else if(error){
           console.log('An error has ocurred');
           console.log(error);
       }
    }

      navigateToPage(event) {
        const page = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
            name: page
            }
        });
    }
}