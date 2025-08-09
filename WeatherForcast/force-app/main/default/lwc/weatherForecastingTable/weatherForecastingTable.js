import { api, LightningElement } from 'lwc';

export default class WeatherForecastingTable extends LightningElement {
     
    @api forcastDaysArray;

    async connectedCallback(){
        this.forcastDaysArray = await this.forcastDaysArray.map(forecastDay =>{
            return {...forecastDay,
                        day:{
                            mintemp:forecastDay.day.mintemp,
                            maxtemp:forecastDay.day.maxtemp,
                            condition:{
                                ...forecastDay.day.condition,
                                class:(forecastDay?.day?.condition?.text?.includes('Cloudy') ? 'table-row blue' : forecastDay?.day?.condition?.text?.includes('Sunny') ? 'table-row orange' : 'table-row gray')
                            }
                        }
            
            };
        });
    }
    

    handleDaySelection(e){
        
        const key = e.currentTarget.dataset.id;
        const selectedDay = this.forcastDaysArray.filter(d=>d.forecastDate == key);
        
        const selectEvent = new CustomEvent('select',{
            detail:{
                forecastDay:selectedDay    
            }
        });

        this.dispatchEvent(selectEvent);
    }

}