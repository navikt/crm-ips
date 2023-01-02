import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { sortList, getMobileSortingOptions } from 'c/sortController';
import Id from '@salesforce/user/Id';
import getUserEducation from '@salesforce/apex/IPS_myWorkTrailController.getUserEducations';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';

const COLUMNS =[
    {label: 'Utdanning', fieldName: 'Name',type: 'text',hideDefaultActions: true},
    {label: 'Navn på utdanning', fieldName: 'ips_Name_of_the_Education_Institution__c', type: 'text', hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 200,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Utdanning',
            variant: 'Brand'
        }
    }
]
export default class Ips_educations extends NavigationMixin(LightningElement){
//currentUser = Id;
currentUser ='0051X00000DtVvmQAF' ;
@track educationRecord;
@track record;
@track defaultSortDirection = 'desc';
@track sortDirection = 'desc';
@track sortedBy = 'ips_Start_Date__c';
recordIds;
isEducation = false;
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

    @wire(getUserEducation, {workTrailId:'$recordIds'})
    userActivity({error,data}){
       if(data){
        if(data.length>0){
            this.educationRecord = data;
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