import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserEducations from '@salesforce/apex/IPS_myWorkTrailController.getallEducations';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';

const COLUMNS =[
    {label: 'Utdanning', fieldName: 'Name',type: 'text',hideDefaultActions: true},
    {label: 'Utdanningssted', fieldName: 'ips_Name_of_the_Education_Institution__c', type: 'text', hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 170,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Utdanning',
            variant: 'Brand'
        }
    },
    {
        type:'button',
        fixedWidth: 170,
        typeAttributes:{
            label: 'Fullført',
            title: 'Fullført',
            name: 'Status',
            variant: 'Destructive',
            disabled:{fieldName:'disableButton'}
        }
        
    }
]
export default class Ips_educations extends NavigationMixin(LightningElement){
currentUser = Id;
//currentUser ='0051X00000EABDRQA5' ;
educationRecords;
@track educationRecord;
@track record;
recordIds;
isEducation = false;
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

    @wire(getUserEducations, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.educationRecords = data;
            this.educationRecord = JSON.parse(JSON.stringify(this.educationRecords));
            this.educationRecord.forEach(edu => {
              edu.disableButton = edu.ips_Status__c !== 'Completed';
            });
            this.isEducation = true;
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