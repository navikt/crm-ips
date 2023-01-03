import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { sortList, getMobileSortingOptions } from 'c/sortController';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getUserWorkTrainings from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrainings';

const COLUMNS =[
    {label: 'Arbeidstrening', fieldName: 'Name',type: 'text',hideDefaultActions: true},
    {label: 'Type', fieldName: 'ips_Form_of_Employment__c', type: 'text', hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 200,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Arbeidstrening',
            variant: 'Brand'
        }
    }
]

export default class Ips_myWorkTrainings extends NavigationMixin(LightningElement) {
//currentUser = Id;
currentUser ='0051X00000DtVvmQAF' ;
@track trainingRecord;
@track record;
@track defaultSortDirection = 'desc';
@track sortDirection = 'desc';
@track sortedBy = 'ActivityDate';
recordIds;
isTraining = false;
columns = COLUMNS;

onHandleSort(event) {
    this.sortDirection = event.detail.sortDirection;
    this.sortedBy = event.detail.fieldName;
    this.workOrders = sortList(this.workOrders, this.sortedBy, this.sortDirection);
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

    @wire(getUserWorkTrainings, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.trainingRecord = data;
            this.isTraining = true;
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