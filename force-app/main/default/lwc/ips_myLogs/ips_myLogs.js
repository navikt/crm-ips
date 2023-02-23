import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getParticipantsLogs from '@salesforce/apex/IPS_myActivityController.getParticipantsLogs';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myLogs extends NavigationMixin(LightningElement) {
myLoggImg = IPS_HOME_LOGOS + '/PeopleDialogFilled.svg';
currentUser = Id;
//currentUser ='0053O000007R0NUQA0' ;
@track loggRecords;
@track record;
recordIds;
@track isLogg = false;


/* Fetch recordId from logged in user */
    @wire(getUserWorkTrailId,{userId: '$currentUser'})
    wiredtrail({ error, data }) {
            if (data) {
                this.record = data[0];
                this.recordIds = this.record?.Id;
            } else if (error) {
                console.log('Something went wrong:', error);
            }
        }

    @wire(getParticipantsLogs, {workTrailId:'$recordIds'})
    userGoal({error,data}){
       if(data){
        if(data.length>0){
            this.loggRecords = data;
            this.isLogg = true;
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
