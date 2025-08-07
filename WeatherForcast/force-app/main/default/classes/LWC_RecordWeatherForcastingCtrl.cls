public with sharing class LWC_RecordWeatherForcastingCtrl {

    @AuraEnabled(cacheable=true)
    public static String getWeatherForecast(String recordId, Integer numOfDays) {
            
        SObject record = fetchRecordWithCoordinates(recordId);
        if (record == null) return null;

        ExternalService.WeatherAPI.getForecast_Request request = buildForecastRequest(recordId, record, numOfDays);
        ExternalService.WeatherAPI service = new ExternalService.WeatherAPI();
        System.debug('## req =  ' + request);
        ExternalService.WeatherAPI.getForecast_Response response = service.getForecast(request);

        System.debug('### res = ' + JSON.serialize(response.Code200.forecast.forecastday));
        return JSON.serialize(response.Code200);
      
    }

    private static SObject fetchRecordWithCoordinates(String recordId) {
        
        String sObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());

        Record_Weather_Location_Fields__mdt mapping = Record_Weather_Location_Fields__mdt.getInstance(sObjectType);
        
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

    private static ExternalService.WeatherAPI.getForecast_Request buildForecastRequest(String recordId, SObject record, Integer numOfDays) {
       
        String sObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());

        Record_Weather_Location_Fields__mdt mapping = Record_Weather_Location_Fields__mdt.getInstance(sObjectType);

        List<String> fieldNames = new List<String>{
            mapping.Latitude_Field_Api_Name__c,
            mapping.Longitude_Field_Api_Name__c
        };

        String locationQuery = '';

        for (Integer i = 0; i < fieldNames.size(); i++) {

            String fieldName = fieldNames[i];
            locationQuery += record.get(fieldName);

            if (i < fieldNames.size() - 1) {
                locationQuery += ',';
            }
        }

        Callouts_Credentials__c credentials = Callouts_Credentials__c.getValues('WeatherAPI');

        ExternalService.WeatherAPI.getForecast_Request req = new ExternalService.WeatherAPI.getForecast_Request();
        req.key = credentials.API_Key__c;
        req.days = numOfDays;
        req.q = locationQuery;

        return req;
    }
}
