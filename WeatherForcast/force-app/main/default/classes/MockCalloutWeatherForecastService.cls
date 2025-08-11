global with sharing class MockCalloutWeatherForecastService  implements HttpCalloutMock {
   
    global HttpResponse respond(HttpRequest req) {
        
        
        WeatherForcastModel model = new WeatherForcastModel();
        model.forecast            = new WeatherForcastModel.Forecast();
        model.location            = new WeatherForcastModel.Location();
        
        model.location.country     = 'Israel';
        model.location.name        = 'Tel-Aviv';
        model.location.tz_id       = 'Jerusalem/IL';
        model.forecast.forecastday = new List<WeatherForcastModel.ForecastDay>();
        
        for(Integer i =0; i <= 1; i++){

            WeatherForcastModel.ForecastDay forecastDay = new WeatherForcastModel.ForecastDay();
            WeatherForcastModel.Day day                 = new WeatherForcastModel.Day();
            WeatherForcastModel.Condition condition     = new WeatherForcastModel.Condition();

            condition.icon = 'test.jpg';
            condition.text = 'Sunny';
            
            day.condition   = condition;
            day.avghumidity = 12;
            day.maxtemp     = 25.5d;
            day.mintemp     = 12.5d;
            day.maxwind     = 12;
            
            forecastDay.day = day;
            model.forecast.forecastday.add(forecastDay);
        }
        
        HttpResponse res  = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody(JSON.serialize(model));

        return res;
   }
}