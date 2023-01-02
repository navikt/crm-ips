import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getAllActivity from '@salesforce/apex/IPS_myActivityController.getAllActivity';

const COLUMNS =[
    {
        label: 'Møtedato', 
        fieldName: 'ActivityDate',
        type: 'date',
        hideDefaultActions: true,
            typeAttributes:{
            year:"numeric" ,
            month:"numeric" ,
            day:"2-digit" ,
            weekday:"long"
        }
    },
    {label: 'Emne', fieldName: 'Subject', type: 'text', hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 170,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Møte',
            variant: 'Brand'
        }
    },
    {
        type:'button',
        fixedWidth: 170,
        typeAttributes:{
            label: 'Lukket',
            title: 'Lukket',
            name: 'IPS_Status1__c',
            variant: 'Destructive',
            disabled:{fieldName:'disableButton'}
        }
    }
]

export default class Ips_myMeetings extends NavigationMixin(LightningElement) {
//currentUser = Id;
currentUser ='0051X00000DtVvmQAF' ;
activityRecords;
@track activityRecord
@track record;
recordIds;
isActivity = false;
columns = COLUMNS;


get isMobile() {
    return window.screen.width < 576;
  }

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

    @wire(getAllActivity, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.activityRecords = data;
            this.activityRecord = JSON.parse(JSON.stringify(this.activityRecords));
            this.activityRecord.forEach(act => {
              act.disableButton = act.IPS_Status1__c !== 'Completed';
            });
            this.isActivity = true;
        }
       }else if(error){
           console.log('An error has ocurred');
           console.log(error);
       }
    }

    handleRowAction(event) {
        console.log('eventId: '+ event.detail.row.Id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: event.detail.row.Id,
              actionName: 'view'
            }
          });
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