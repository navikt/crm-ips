import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getParticipantActivity from '@salesforce/apex/IPS_myActivityController.getParticipantActivity';
import USER_ID from '@salesforce/user/Id';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myActivityUO extends NavigationMixin(LightningElement) {
    @api recordId;
    record;
    activityPartRecord;
    //@track userIds = USER_ID;
    @track userIds = '0051X00000DAHjSQAX';
    typeMeeting ='Participant';

    myActivityImg = IPS_HOME_LOGOS + '/CalenderFilled.svg';

    @wire(getParticipantActivity, {userId:'$userIds',typeOfMeeting:'$typeMeeting'})
    userPartActivity({error,data}){
        console.log('Dette er data fra wire: '+JSON.stringify(data));
       if(data){
           this.activityPartRecord = data;
       }else if(error){
           this.isNoData = true;
           console.log('An error has ocurred');
           console.log(error);
       }
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