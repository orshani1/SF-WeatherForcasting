import { LightningElement, api } from 'lwc';
import CAL_ICON                  from '@salesforce/label/c.weather_cal';
import LOC_ICON                  from '@salesforce/label/c.weather_loc';
import WIND_ICON                 from '@salesforce/label/c.weather_wind';

export default class WeatherForecastDetail extends LightningElement {

    @api forecastDay;

    @api forecast;
    
    @api forecastDaysArray;

  
    calenderIcon = CAL_ICON;
  
    locationIcon = LOC_ICON;
  
    weatherWindIcon = WIND_ICON;

  
    get tempLabel() { return `${this.forecastDay.day.maxtemp} °C`; }
}
