import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { sortList } from 'c/sortController';
import getParticipantsGoals from '@salesforce/apex/IPS_myActivityController.getParticipantsGoals';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';

const COLUMNS =[
    {label: 'Delmål', fieldName: 'Subject',type: 'text',hideDefaultActions: true},
    {
        label: 'Mål dato', 
        fieldName: 'ActivityDate', 
        type: 'date', hideDefaultActions: true,
        typeAttributes:{
            year:"numeric" ,
            month:"numeric" ,
            day:"2-digit" ,
            weekday:"long"
        }
    },
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

export default class Ips_myGoals extends NavigationMixin(LightningElement) {
//currentUser = Id;
currentUser ='0051X00000DtVvmQAF' ;
goalRecords;
@track goalRecord;
@track record;
recordIds;
isGoal = false;
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

    @wire(getParticipantsGoals, {workTrailId:'$recordIds'})
    userGoal({error,data}){
       if(data){
        if(data.length>0){
            this.goalRecords = data;
            this.goalRecord = JSON.parse(JSON.stringify(this.goalRecords));
            this.goalRecord.forEach(goall => {
              goall.disableButton = goall.Status !== 'Completed';
            });
            this.isGoal = true;
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
