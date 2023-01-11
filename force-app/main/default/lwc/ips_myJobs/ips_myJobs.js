import { LightningElement,wire ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import getUserWorks from '@salesforce/apex/IPS_myWorkTrailController.getUserWorks';

const COLUMNS =[
    {label: 'Jobb', fieldName: 'Name',type: 'text',hideDefaultActions: true},
    {
        type: 'button',
        fixedWidth: 200,
        typeAttributes:{
            label: 'Se detaljer',
            title: 'Se detaljer',
            name: 'Jobb',
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

export default class Ips_myJobs extends NavigationMixin(LightningElement) {
currentUser = Id;
//currentUser ='0051X00000DtVvmQAF' ;
@track jobRecord;
jobRecords;
@track record;
recordIds;
isjob = false;
isloading = true;
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

    @wire(getUserWorks, {workTrailId:'$recordIds'})
    userJob({error,data}){
       if(data){
        if(data.length>0){
            this.jobRecords = data;
            this.jobRecord = JSON.parse(JSON.stringify(this.jobRecords));
            this.jobRecord.forEach(job => {
              job.disableButton = job.ips_Status__c !== 'Completed';
            });
            this.loading = false;
            this.isJob = true;
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