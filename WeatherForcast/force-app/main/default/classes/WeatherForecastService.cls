public with sharing class WeatherForecastService {
    
    @AuraEnabled(cacheable=true)
    public static String getWeatherForecast(String recordId,String numOfDays){

        
        String q = '';

        String sObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());
        Record_Weather_Location_Fields__mdt mapping = Record_Weather_Location_Fields__mdt.getInstance(sObjectType);
        
        SObject obj = fetchRecordWithCoordinates(recordId,mapping,sObjectType);
        q += obj.get(mapping.Latitude_Field_Api_Name__c) + ',' + obj.get(mapping.Longitude_Field_Api_Name__c);


        return JSON.serialize(callService(q, numOfDays));
    }

    public static WeatherForcastModel callService(String q,String numOfDays){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        
        req.setEndpoint('callout:Weather_API/v1/forecast.json?key=' + Callouts_Credentials__c.getValues('WeatherAPI').API_Key__c + '&q=' + q + '&days='+numOfDays);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        
        res = http.send(req);

        WeatherForcastModel model =(WeatherForcastModel) JSON.deserialize(res.getBody(),WeatherForcastModel.class);
        model = fillModelInvalidIdentifiers(model, res);

        
    
        return model;
    }

    private static WeatherForcastModel fillModelInvalidIdentifiers(WeatherForcastModel model, HttpResponse res){
        
        Map<String, Object> bodyMap =       (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> forecastMap =   (Map<String, Object>) bodyMap.get('forecast');

        List<Object> forecastDays =         (List<Object>) forecastMap.get('forecastday');

        Map<String, WeatherForcastModel.ForecastDay> dateToDayMap = new Map<String, WeatherForcastModel.ForecastDay>();

        for (WeatherForcastModel.ForecastDay foreCastDay : model.forecast.forecastday) {
            dateToDayMap.put(String.valueOf(foreCastDay.date_epoch), foreCastDay);
        }

       for (Object obj : forecastDays) {
            Map<String, Object> forecastDayMap = (Map<String, Object>) obj;
            String epochStr = String.valueOf(forecastDayMap.get('date_epoch'));

            if (dateToDayMap.containsKey(epochStr)) {
                WeatherForcastModel.ForecastDay forecastDay = dateToDayMap.get(epochStr);

                Map<String, Object> rawDayMap = (Map<String, Object>) forecastDayMap.get('day');

                forecastDay.forecastDate = (String) forecastDayMap.get('date');
                forecastDay.day.maxtemp = (Decimal) rawDayMap.get('maxtemp_c');
                forecastDay.day.mintemp = (Decimal) rawDayMap.get('mintemp_c'); 
                forecastDay.day.maxwind = (Decimal) rawDayMap.get('maxwind_mph'); 
            }
        }


        model.forecast.forecastday = dateToDayMap.values();
        return model;
    }
    
    private static SObject fetchRecordWithCoordinates(String recordId,Record_Weather_Location_Fields__mdt mapping,String sObjectType) {
        
        if (mapping == null) return null;

        List<String> fieldNames = new List<String>{
            mapping.Latitude_Field_Api_Name__c,
            mapping.Longitude_Field_Api_Name__c
        };

        Map<String, Object> bindMap = new Map<String, Object>{ 'recordId' => recordId };
        
        String query = 'SELECT Id';
        
        for (String field : fieldNames) {
            query += ', ' + field;
        }

        query += ' FROM ' + sObjectType + ' WHERE Id =:recordId';

        return Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
    }
        
}