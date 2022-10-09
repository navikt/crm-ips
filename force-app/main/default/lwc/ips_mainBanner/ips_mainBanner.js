import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.FirstName';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_mainBanner extends LightningElement {
@track name;
/*fetch name from logged in user */
@wire(getRecord,{
    recordId: [USER_ID],
    fields: [NAME_FIELD]
})

wireuser({data}){
    if(data){
        this.name = data.fields.FirstName.value;
    }
}

/* profile logo */
myProfileImg = IPS_HOME_LOGOS + '/ProfileFilled.svg';

}