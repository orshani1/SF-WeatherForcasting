import { LightningElement, api } from 'lwc';

export default class WeatherForecastingTable extends LightningElement {
 
    @api days; 

 
    handleDaySelection(e) {
 
        const epoch = Number(e.currentTarget.dataset.epoch);
        
        const day = this.days.find(d => Number(d.date_epoch) === epoch);
        
        this.dispatchEvent(new CustomEvent('forecastselect', { detail: { day } }));
    } 

    get rows() {
        if (!this.days) return [];
        return this.days.map(d => {
            
            const t = (d?.day?.condition?.text || '').toLowerCase();
            
            const tone = t.includes('cloud') ? 'blue' : t.includes('sunny') ? 'orange' : 'gray';
            
            return { ...d, _rowClass: `table-row ${tone}` };
        });
  }
}
