import { api, LightningElement, track } from 'lwc';

export default class WeatherForecastDetail extends LightningElement {
    
    @api forecastDay;

    @api forecast;

    @api forecastDaysArray;

    calenderIcon = 'https://cdn-icons-png.flaticon.com/512/4744/4744824.png';

    locationIcon = 'https://cdn-icons-png.flaticon.com/512/535/535239.png';

    weatherWindIcon = 'https://cdn-icons-png.flaticon.com/512/6143/6143028.png';

    renderedCallback(){
        if(this.forecast && this.forecast.location){
            console.log('### location = ' + JSON.stringify(this.forecastDaysArray[0].day));
            
        }
    }

    get isDayRendered(){
            return this.forecastDay && this.forecastDay.day && this.forecastDay.day.condition && this.forecastDay.day.condition.icon  && this.forecast && this.forecast.location;        
    }
}