import { LightningElement ,api, wire, track} from 'lwc';

import getTrailStatus from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailStatus';
import getReferred from '@salesforce/apex/IPS_ManagerTrailController.getReferredTrails';
import getTrailJobbspesialist from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedTrailJobbspesialist';
import getEndedTrail from '@salesforce/apex/IPS_ManagerTrailController.getAggregatedEndedTrail';

export default class Ips_ManagerTrails extends LightningElement {
    @track error;
    @track trailStatusIPS=[];
    isIPS = false;
    isSE = false;
    @track trailStatusSE=[];
    @track trailReferredList;
    @track trailOwnerList;
    @track trailEndedList;

  
    initialRecordOwnerList;
    initialRecordEventList;

    isIPSReferred = false;
    isSEReferred = false;
    @track referredNumberIPS = 0;
    @track endedNumberIPS = 0;
    @track endedToWorkIPS = 0;
    @track referredNumberSE = 0;
    @track endedNumberSE = 0;
    @track endedToWorkSE = 0;

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
            let tempEndedListIPS =0;
            let tempReferredListIPS =0;
            let tempCauseIPS = 0;
            let tempEndedListSE =0;
            let tempReferredListSE =0;
            let tempCauseSE = 0;
            
            for(var i=0;i<data.length;i++){
                if(data[i].service==='IPS'){
                    if(data[i].trailStatus==='Ended'){
                        tempEndedListIPS = data[i].numberOfTrail;
                        this.isIPSReferred = true;
                        if(data[i].cause==='Work'){
                            tempCauseIPS ++;
                        }
                    }
                    if(data[i].trailStatus==='Referred'){
                        tempReferredListIPS = data[i].numberOfTrail;
                        this.isIPSReferred = true;
                    }
                }
                if(data[i].service==='Supported Employment'){
                    if(data[i].trailStatus==='Ended'){
                        tempEndedListSE = data[i].numberOfTrail;
                        this.isSEReferred = true;
                        if(data[i].cause==='Work'){
                            tempCauseSE ++;
                        }
                    }
                    if(data[i].trailStatus==='Referred'){
                        tempReferredListSE = data[i].numberOfTrail;
                        this.isSEReferred = true;
                    }
                }
            }
            this.referredNumberIPS = tempReferredListIPS;
            this.endedNumberIPS = tempEndedListIPS;
            this.referredNumberSE = tempReferredListSE;
            this.endedNumberSE = tempEndedListSE;
            this.endedToWorkIPS = tempCauseIPS;
            this.endedToWorkSE = tempCauseSE;
         }else if(error){
             this.error = error;
         }
     }

     /* get all trails pr status */
    @wire(getTrailStatus)
    wiredStatuses({error, data}){
        if(data){
            console.log(JSON.stringify(data));
            let tempIPS =[];
            let tempSE = [];

            for(var i=0; i<data.length; i++){
                if(data[i].service==='IPS'){
                    tempIPS.push(data[i]);
                    this.isIPS = true;
                }
                if(data[i].service==='Supported Employment'){
                    tempSE.push(data[i]);
                    this.isSE = true;
                }
            }
            this.trailStatusIPS = tempIPS;
            this.trailStatusSE = tempSE;
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