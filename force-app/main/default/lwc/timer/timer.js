import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import MINUTESSPENT_FIELD from '@salesforce/schema/Event__c.Minutes_Spent__c';

const FIELDS = [
    MINUTESSPENT_FIELD
];

export default class Timer extends LightningElement {
 
    @api recordId;
    
    record;
    error;
    timer; 
    interval;
    startMs = new Date().getTime();
    startingValue;
    
    connectedCallback(){

        console.log('recordId: ', this.recordId);
        console.log('Start MS: ', this.startMs);

        window.addEventListener('beforeunload', this.updateMinutesSpent.bind(this));
    }

    startTimer(evt){
        console.log('Starting timer');
        let _parent = this;

        this.interval = setInterval(function(){

            // we grab the actual ms from time because intervals might not run exactly at the specified interval
            // and could show a difference in actuality
            let ms = new Date().getTime();

            try {
                // this value isn't currently used, but could be used to show on-screen if the timer was to be displayed
                _parent.timer = ms - _parent.startMs;
            } catch (err){
                console.log(err);
            }
            

        }, 1000);
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    eventRecord({ error, data }) {
        if (error) {
            console.log('error', error);
            this.error = error;
            this.record = undefined;
        } else if (data) {
            console.log('data', data);
            this.record = data;
            this.error = undefined;
            
            this.startingValue = this.record.fields.Minutes_Spent__c.value;

            /*// calculating the value periodically for display purposes
            this.interval = setInterval(function(){

                // we grab the actual ms from time because intervals might not run exactly at the specified interval
                // and could show a difference in actuality
                let ms = new Date().getTime();
    
                try {
                    // this value isn't currently used, but could be used to show on-screen if the timer was to be displayed
                    _parent.timer = ms - _parent.startMs;
                } catch (err){
                    console.log(err);
                }
                
    
            }, 1000);*/
        }
      }
    
    // when navigating away, we recalculate at moment so that we get specific values
    async updateMinutesSpent(e){
        console.log('Stopping timer');

        let currentTime = new Date().getTime();
        let timeDiff = Math.floor((currentTime - this.startMs) / 1000 / 60);
        let updatedTime = this.startingValue + timeDiff;

        console.log('updating Minutes Spent', this.startingValue, updatedTime);
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[MINUTESSPENT_FIELD.fieldApiName] = updatedTime;

        const recordInput = { fields };
            
        let response = await updateRecord(recordInput);

        clearInterval(this.interval);
        this.startingValue = updatedTime;
        this.startMs = new Date().getTime();
    }
}