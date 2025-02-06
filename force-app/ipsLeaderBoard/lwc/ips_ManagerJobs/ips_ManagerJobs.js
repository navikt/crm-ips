import { LightningElement, wire, track } from 'lwc';
import getJobCategory from '@salesforce/apex/IPS_jobController.totalJobsByCategory';
import getJobTraining from '@salesforce/apex/IPS_jobController.totalJobTraining';
import getUOTraining from '@salesforce/apex/IPS_ManagerTrailController.getUOTraining';

export default class Ips_ManagerJobs extends LightningElement {
    @track columnstotalCategory = [
        { label: 'Ansettelsesform', fieldName: 'typeOfEmployment', type: 'text' },
        { label: 'Antall', fieldName: 'totalNumber', type: 'Number' }
    ];

    @track jobCategoryList;
    @track jobTrainingList;
    @track uoTrainingList;
    @track jobTrainingNumber = 0;
    @track jobPaidNumber = 0;
    @track uoTrainingNumber = 0;
    @track ipsTrainingNumber = 0;

    @wire(getJobCategory)
    wiredCategory({ error, data }) {
        if (data) {
            let tempTotalJobs = 0;

            for (let i = 0; i < data.length; i++) {
                tempTotalJobs += data[i].totalNumber;
            }
            this.jobPaidNumber = tempTotalJobs;
            this.jobCategoryList = data;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getJobTraining)
    wiredTraining({ error, data }) {
        if (data) {
            this.jobTrainingList = data[0];
            this.jobTrainingNumber = this.jobTrainingList?.totalNumber;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getUOTraining)
    wiredUOTrain({ error, data }) {
        if (data) {
            this.uoTrainingList = data[0];
            this.uoTrainingNumber = this.uoTrainingList?.numberOfTrail;
        } else if (error) {
            this.error = error;
        }
    }
}
