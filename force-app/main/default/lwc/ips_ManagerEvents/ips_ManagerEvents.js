import { LightningElement ,api, wire, track} from 'lwc';
import getEventList from '@salesforce/apex/ips_ManagerEventController.getEventsForCurrentWeek';
import getTrailStatus from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailStatus';
import getTrailJobbspesialist from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailJobbspesialist';
import getManagerUsers from '@salesforce/apex/IPS_ManagerTrailController.getManagerUsers';
import getEndedTrail from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedEndedTrail';

export default class Ips_ManagerEvents extends LightningElement {

    @track columns = [
        { label: 'Jobbspesialist', fieldName: 'employeeName', type: 'text'},
        { label: 'Tid', fieldName: 'startTime', type: 'text'},
        { label: 'Emne', fieldName: 'subject', type: 'text' },
        { label: 'Sted', fieldName: 'location', type: 'text'},
        { label: 'Deltaker', fieldName: 'participantName', type: 'text'},
        { label: 'Fødselsnr', fieldName: 'participantIdent', type: 'text' },
        { label: 'Hjemmeadresse', fieldName: 'participantAddress', type: 'text' },
    ];

    @track columnstrailStatus = [
        { label: 'Status/fase', fieldName: 'trailStatus', type: 'text'},
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ];

    @track columnstrailOwner = [
        { label: 'Jobbspesialist', fieldName: 'employeeName', type: 'text'},
        { label: 'Status/fase', fieldName: 'trailStatus', type: 'text'},
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ];

    @track columnstrailEnded =[
        { label: 'År', fieldName: 'year', type: 'text'},
        { label: 'Måned', fieldName: 'month', type: 'text'},
        { label: 'Årsak', fieldName: 'cause', type: 'text' },
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ];

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track error;
    @track eventList ;
    @track trailStatusList;
    @track trailOwnerList;
    @track trailEndedList;
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
    
    /* get all events the next 7 days */
    @wire(getEventList)
    wiredAEvents({
        error,
        data
    }) {
        if (data) {
            this.eventList = data;
            this.eventList = data;
        } else if (error) {
            this.error = error;
            console.log(error);
        }
    }

    /* get all trails pr status */
    @wire(getTrailStatus)
        wiredStatuses({error, data}){
            if(data){
                this.trailStatusList = data;
            }else if(error){
                this.error = error;
            }
        }

    /* get all trails pr jobbspesialist */
    @wire(getTrailJobbspesialist)
        wiredOwners({error, data}){
            if(data){
                this.trailOwnerList = data;
                this.initialRecordOwnerList = data;
            }else if(error){
                this.error = error;
            }
        }

    /* get all ended aggregated pr year,month,cause */
    @wire(getEndedTrail)
        wiredEnds({error,data}){
            if(data){
                this.trailEndedList = data;
            }else if(error){
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