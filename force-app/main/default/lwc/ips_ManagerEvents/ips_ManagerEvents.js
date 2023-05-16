import { LightningElement ,api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import getManagerUsers from '@salesforce/apex/IPS_ManagerEventController.getManagerUsers';
import getEventList from '@salesforce/apex/ips_ManagerEventController.getEventsForCurrentWeek';
import getJobCategory from '@salesforce/apex/IPS_jobController.totalJobsByCategory';
import getJobTraining from '@salesforce/apex/IPS_jobController.totalJobTraining';
import UserNameFIELD from '@salesforce/schema/User.Name';


export default class Ips_ManagerEvents extends LightningElement {

    @track columns = [
        { label: 'Jobbspesialist', fieldName: 'employeeName', type: 'text'},
        { label: 'Tid', fieldName: 'startTime', type: 'text'},
        { label: 'Emne', fieldName: 'subject', type: 'text' },
        { label: 'Sted', fieldName: 'location', type: 'text'},
        { label: 'Møtetype', fieldName: 'meetingCategory', type: 'text'},
        { label: 'Deltaker', fieldName: 'participantName', type: 'text'},
        { label: 'Fødselsnr', fieldName: 'participantIdent', type: 'text' },
    ];



    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track error;
    @track eventList ;
    @track currentUserName;
    
    @track userOptions=[];
    @track value='- Alle -';
    @track optionsLoaded = false;
    initialRecordOwnerList;
    initialRecordEventList;
    

    connectedCallback(){
        getManagerUsers()
        .then(result=>{
            this.userOptions.push({label:this.value, value:this.value});
            for(var i=0; i<result.length; i++){
                this.userOptions.push({label:result[i].employeeName, value:result[i].employeeId});
            }
            this.optionsLoaded = true;
        })
        .catch(error=> {
            alert(JSON.stringify(error));
        })

    }
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD]}) 
    currentUserInfo({error, data}){
        if(data){
            this.currentUserName = data.fields.Name.value;
        }
    }

   

    
    /* get all events the next 7 days */
    @wire(getEventList)
    wiredAEvents({error,data}) {
        if (data) {
            this.eventList = data;
        } else if (error) {
            this.error = error;
        }
    } 

   

    handleUserChange(event){
        console.log(event.detail.value);
        this.value = event.detail.value;
        const searchKey = event.target.value;
        if(searchKey){

            this.eventList = this.initialRecordEventList;
            this.trailOwnerList = this.initialRecordOwnerList;

            if(this.eventList){
                let recEvent =[];
                for(let recE of this.eventList){

                }
            }

            let records = [];
            for(let rec of this.trailList){

            }

        }
    }
}