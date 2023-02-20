import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getUserJobs from '@salesforce/apex/IPS_jobController.getCompletedUserJobs';


export default class Ips_myJobs extends NavigationMixin(LightningElement) {
currentUser = Id;
//currentUser ='0053O000007R0NUQA0' ;
@track jobRecords;
@track record;
recordIds;
isjob = false;

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

    @wire(getUserJobs, {workTrailId:'$recordIds'})
    userJob({error,data}){
       if(data){
        if(data.length>0){
            this.jobRecords = data;
            this.isJob = true;
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