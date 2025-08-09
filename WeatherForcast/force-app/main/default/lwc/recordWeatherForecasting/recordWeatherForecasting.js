import { api, LightningElement,wire,track } from 'lwc';
import getWeatherForecast                   from '@salesforce/apex/WeatherForecastService.getWeatherForecast';

export default class RecordWeatherForecasting extends LightningElement {
    
    @api recordId;

    @track forecastDaysArray = [];

    @track currentForecast = {};
    
    @track forecastObj = {};
    
   
    @track dataReady = false;

    @wire(getWeatherForecast, { recordId: "$recordId", numOfDays: 7 })
    forecastWeather({ error, data }) {
       
        if (data) {
            const parsedData = JSON.parse(data);
            const days = parsedData?.forecast?.forecastday;

            this.forecastDaysArray = days;
            this.currentForecast = days[0];
            this.forecastObj = parsedData;
          
            this.dataReady = true;
        }
    }
    




    handleSelect(e){
        this.currentForecast = this.forecastDaysArray.filter(d=> d.forecastDate == e.detail.forecastDay[0].forecastDate)[0];
    }


}