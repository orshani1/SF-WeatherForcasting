import { api, LightningElement } from 'lwc';

export default class WeatherForecastingTable extends LightningElement {
     
    @api forcastDaysArray;

    async connectedCallback(){
        this.forcastDaysArray = await this.forcastDaysArray.map(forecastDay =>{
            return {...forecastDay,
                        day:{
                            mintempx5fc:forecastDay.day.mintempx5fc,
                            maxtempx5fc:forecastDay.day.mintempx5fc,
                            condition:{
                                ...forecastDay.day.condition,
                                class:(forecastDay.day.condition.text.includes('Cloudy') ? 'table-row blue' : forecastDay.day.condition.text.includes('Sunny') ? 'table-row orange' : 'table-row gray')
                            }
                        }
            
            };
        });
    }

    handleDaySelection(e){
        debugger;
        console.log('e = ' + JSON.stringify(e.detail));
        console.log('e target = ' + JSON.stringify(e.target));
        debugger;

        
    }

}