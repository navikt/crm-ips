import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserEducations from '@salesforce/apex/IPS_myWorkTrailController.getallEducations';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_educations extends NavigationMixin(LightningElement){
myEduImg = IPS_HOME_LOGOS + '/EmployerFilled.svg';
currentUser = Id;
//currentUser ='0053O000007R0NUQA0' ;
@track educationRecords;
@track record;
recordIds;
isEducation = false;


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

    @wire(getUserEducations, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.educationRecords = data;
            this.isEducation = true;
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