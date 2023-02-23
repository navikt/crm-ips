import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getParticipantsGoals from '@salesforce/apex/IPS_myActivityController.getAllGoals';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';


export default class Ips_myGoals extends NavigationMixin(LightningElement) {
myGoalImg = IPS_HOME_LOGOS + '/TaskFilled.svg';
//currentUser = Id;
currentUser ='0053O000007R0NUQA0' ;
@track goalRecords;
@track record;
recordIds;
recordtypename;
@track isGoal = false;


/* Fetch recordId from logged in user */
    @wire(getUserWorkTrailId,{userId: '$currentUser'})
    wiredtrail({ error, data }) {
            if (data) {
                this.record = data[0];
                this.recordIds = this.record?.Id;
                this.recordtypename =this.record?.RecordType.DeveloperName;
            } else if (error) {
                console.log('Something went wrong:', error);
            }
        }

        get isIPS(){
            if(this.recordtypename === 'IPS'){
                return true;
            }
            if(this.recortypename === 'ips_Supported_Employment'){
                return false;
            }
        }

    @wire(getParticipantsGoals, {workTrailId:'$recordIds'})
    userGoal({error,data}){
       if(data){
        if(data.length>0){
            this.goalRecords = data;
            this.isGoal = true;
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
