import { api, LightningElement,wire } from 'lwc';
import { getRecord }                  from 'lightning/uiRecordApi';
import getWeatherForecast             from '@salesforce/apex/LWC_RecordWeatherForcastingCtrl.getWeatherForecast';
export default class RecordWeatherForecasting extends LightningElement {
    
    @api recordId;

    
    @wire(getWeatherForecast, { recordId: "$recordId"})
    forecastWeather ({error, data}) {
        if (error) {
            // TODO: Error handling
        } else if (data) {
            // TODO: Data handling
        }
    }
}