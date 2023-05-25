import { LightningElement ,api, wire, track} from 'lwc';

import getTrailStatus from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailStatus';
import getReferred from '@salesforce/apex/IPS_ManagerTrailController.getReferredTrails';
import getTrailJobbspesialist from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailJobbspesialist';
import getEndedTrail from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedEndedTrail';

export default class Ips_ManagerTrails extends LightningElement {
    @track error;
    @track trailStatusList;
    @track trailReferredList;
    @track trailOwnerList;
    @track trailEndedList;
  
    initialRecordOwnerList;
    initialRecordEventList;
    @track referredNumber = 0;
    @track endedNumber = 0;

    @track columnstrailStatus = [
        { label: 'Status/fase', fieldName: 'trailStatus', type: 'text'},
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ];

    @track columnstrailOwner = [
        { label: 'Medarbeider', fieldName: 'employeeName', type: 'text'},
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ];

    @track columnstrailEnded =[
        { label: 'År', fieldName: 'year', type: 'text'},
        { label: 'Måned', fieldName: 'month', type: 'text'},
        { label: 'Årsak', fieldName: 'cause', type: 'text' },
        { label: 'Underårsak', fieldName: 'subCause',type: 'text'},
        { label: 'Antall', fieldName: 'numberOfTrail', type: 'Number' },
    ]; 


     /* get total ended trails */
     @wire(getReferred)
     wiredReferred({error, data}){
         if(data){
            var tempEndedList =0;
            var tempReferredList =0;
            
            for(var i=0;i<data.length;i++){
                if(data[i].trailStatus=='Ended'){
                    tempEndedList = data[i].numberOfTrail;
                }
                if(data[i].trailStatus=='Referred'){
                    tempReferredList = data[i].numberOfTrail;;
                }
            }

            this.referredNumber = tempReferredList;
            this.endedNumber = tempEndedList;
         }else if(error){
             this.error = error;
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
}