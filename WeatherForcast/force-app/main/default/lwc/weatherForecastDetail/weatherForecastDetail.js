import { api, LightningElement, track } from 'lwc';

export default class WeatherForecastDetail extends LightningElement {
    
    @api forecastDay;

    @api forecast;

    @api forecastDaysArray;

    calenderIcon = 'https://cdn-icons-png.flaticon.com/512/4744/4744824.png';

    locationIcon = 'https://cdn-icons-png.flaticon.com/512/535/535239.png';

    weatherWindIcon = 'https://cdn-icons-png.flaticon.com/512/6143/6143028.png';


    
}