import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getParticipantsLogs from '@salesforce/apex/IPS_myActivityController.getParticipantsLogs';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';

const COLUMNS =[
    {
        label: 'Dato', 
        fieldName: 'ActivityDate', 
        type: 'date', hideDefaultActions: true,
        typeAttributes:{
            year:"numeric" ,
            month:"numeric" ,
            day:"2-digit" ,
            weekday:"long"
        }
    },
    {label: 'Samtale', fieldName: 'Subject',type: 'text',hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 150,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Goal',
            variant: 'Brand'
        }
    },
    {
        type:'button',
        fixedWidth: 150,
        typeAttributes:{
            label: 'Fullført',
            title: 'Fullført',
            name: 'Status',
            variant: 'Destructive',
            disabled:{fieldName:'disableButton'}
        }
        
    }
]

export default class Ips_myLogs extends NavigationMixin(LightningElement) {
//currentUser = Id;
currentUser ='0051x00000CiK8WAAV' ;
loggRecords;
@track loggRecord;
@track record;
recordIds;
isLogg = false;
columns = COLUMNS;
isloading = true;

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

    @wire(getParticipantsLogs, {workTrailId:'$recordIds'})
    userGoal({error,data}){
       if(data){
        if(data.length>0){
            this.loggRecords = data;
            this.loggRecord = JSON.parse(JSON.stringify(this.loggRecords));
            this.loggRecord.forEach(logg => {
              logg.disableButton = logg.Status !== 'Completed';
            });
            this.isLogg = true;
            this.isloading = false;
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
