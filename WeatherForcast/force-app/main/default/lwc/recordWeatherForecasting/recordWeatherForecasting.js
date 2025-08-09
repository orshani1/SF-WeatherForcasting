import { LightningElement, api, track, wire }   from 'lwc';
import { getRecord }                            from 'lightning/uiRecordApi';
import getForecastImperative                    from '@salesforce/apex/WeatherForecastService.getForecastImperative';

import getMappingFields                         from '@salesforce/apex/WeatherForecastService.getMappingFields';

export default class RecordWeatherForecasting extends LightningElement {
  
    @api recordId;

    @track state =        { loading: true, error: null };
    @track forecast =     null;        
    @track days =         [];              
    @track currentDay =   null;      


    @track dynamicFields = []; 


    @wire(getMappingFields, { recordId: '$recordId' })
    async wiredFields({ data, error }) {
        if (data) {
            this.dynamicFields = await data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields:'$dynamicFields'})
    async handleRecord({ data, error }) {

        if (error) { this.state = { loading:false, error: 'Record load failed' }; return; }

        if (!data)  return;

        
        this.state = { loading: true, error: null };

        let res = await getForecastImperative({ recordId: this.recordId, numOfDays: 7 });
        res = JSON.parse(res);
        
        
        if (!res || res.status !== 'OK') {
            this.state = { loading:false, error: (res && res.message) || 'Service error' };
            return;
        }

        this.forecast = res;
        this.days = res?.forecast?.forecastday || [];

        const nowSec = Math.floor(Date.now() / 1000);
        const tomorrow = this.days.find(d => d.date_epoch > nowSec) || this.days[1] || this.days[0];

        this.currentDay = tomorrow;

        this.state = { loading:false, error: null };
    }


    handleForecastSelect(evt) {
        this.currentDay = evt.detail.day;
    }

    get dataReady() { return !this.state.loading && !this.state.error && this.currentDay; }
}
