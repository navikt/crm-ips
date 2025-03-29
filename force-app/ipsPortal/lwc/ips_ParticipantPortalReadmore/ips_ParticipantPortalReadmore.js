import { LightningElement,api,track } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';

export default class Ips_ParticipantPortalReadmore extends LightningElement {
    @api id = 1;
    @api label;
    @track ariaExpanded = false;
    @api backgroundcolor;
    @api fontsize;
    @api hoverbackgroundcolor;
    @api focusbackgroundcolor;
    @api titlefontweight;

    renderedCallback() { 

        this.setDefaultCssProperties();
        this.initCSSVariables();
    }

    get isMobile() {
        if (formFactorPropertyName === 'Small') {
            return true;
        } else {
            return false;
        }
    }

    initCSSVariables() {
        var css = this.template.host.style;
        css.setProperty('--main-bg-color', this.backgroundcolor);
        css.setProperty('--main-font-size',this.fontsize +'rem');
        css.setProperty('--hover-bg-color',this.hoverbackgroundcolor);
        css.setProperty('--focus-bg-color',this.focusbackgroundcolor);
        css.setProperty('--title-font-weight',this.titlefontweight);
    }

     setDefaultCssProperties() {
        if (this.backgroundcolor === undefined) {
            this.backgroundcolor = '#FFFFFF';
        }

        if(this.fontsize === undefined){
            if(this.isMobile){
                this.fontsize = '1';
            }else{
                this.fontsize = '1.125';
            }
            
        }

        if(this.hoverbackgroundcolor === undefined){
            this.hoverbackgroundcolor = '#E6F0FF';
        }

        if(this.focusbackgroundcolor === undefined){
            this.focusbackgroundcolor = '#E6F0FF'
        }

        if(this.titlefontweight === undefined){
            this.titlefontweight = '600';
        }
    }

    toggleSection(event){
        this.ariaExpanded = !this.ariaExpanded;
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="'+buttonid + '"]');
        if(currentsection.className.search('slds-is-open')==-1){
            currentsection.className = 'slds-section slds-is-open';
        }else{
            currentsection.className = 'slds-section slds-is-close';
        }
    }
}