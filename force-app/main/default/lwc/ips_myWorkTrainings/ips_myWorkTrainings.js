import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getUserWorkTrainings from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrainings';

const COLUMNS =[
    {label: 'Arbeidstrening', fieldName: 'Name',type: 'text',hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 200,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Arbeidstrening',
            variant: 'Brand'
        }
    },
    {
        type:'button',
        fixedWidth: 170,
        typeAttributes:{
            label: 'Fullført',
            title: 'Fullført',
            name: 'ips_Status__c',
            variant: 'Destructive',
            disabled:{fieldName:'disableButton'}
        }
    }
]

export default class Ips_myWorkTrainings extends NavigationMixin(LightningElement) {
currentUser = Id;
//currentUser ='0051X00000DtVvmQAF' ;
@track trainingRecord;
trainingRecords;
@track record;
recordIds;
isTraining = false;
columns = COLUMNS;


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

    @wire(getUserWorkTrainings, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.trainingRecords = data;
            this.trainingRecord = JSON.parse(JSON.stringify(this.trainingRecords));
            this.trainingRecord.forEach(tra => {
              tra.disableButton = tra.ips_Status__c !== 'Completed';
            });
            this.isTraining = true;
        }
       }else if(error){
           console.log('An error has ocurred');
           console.log(error);
       }
    }

    handleRowAction(event) {
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