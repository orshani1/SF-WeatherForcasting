import { api, LightningElement,wire,track } from 'lwc';
import getWeatherForecast                   from '@salesforce/apex/LWC_RecordWeatherForcastingCtrl.getWeatherForecast';

export default class RecordWeatherForecasting extends LightningElement {
    
    @api recordId;

    @track forecastDaysArray = [];

    @track currentForecast = {};
    
    @track forecastObj = {};
    
   
    
    @wire(getWeatherForecast, { recordId: "$recordId",numOfDays:7})
    forecastWeather ({error, data}) {

        if(data){
            const parsedData = JSON.parse(data);
            this.forecastDaysArray = parsedData.forecast.forecastday; 
            this.currentForecast = this.forecastDaysArray[0];
            this.forecastObj = parsedData;
            
        }
        else {
        }
    
    }

    
}