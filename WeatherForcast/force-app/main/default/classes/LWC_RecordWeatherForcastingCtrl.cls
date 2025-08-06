public with sharing class LWC_RecordWeatherForcastingCtrl {
    
    @AuraEnabled(cacheable=true)
    public static String getWeatherForecast(String recordId,Integer numOfDays){
        
        try {    
            
            ExternalService.WeatherAPI service = new ExternalService.WeatherAPI();
            ExternalService.WeatherAPI.getForecast_Request  req = new ExternalService.WeatherAPI.getForecast_Request();
            Callouts_Credentials__c credentials = Callouts_Credentials__c.getValues('WeatherAPI');
            

            Record_Weather_Location_Fields__mdt weatherFieldMappingMdt = Record_Weather_Location_Fields__mdt.getInstance(String.valueOf(Id.valueOf(recordId).getSobjectType()));
            if(weatherFieldMappingMdt != null){
                
                String query = 'SELECT Id';

                List<String> fieldsNames = new List<String>{weatherFieldMappingMdt.Latitude_Field_Api_Name__c,
                                                            weatherFieldMappingMdt.Longitude_Field_Api_Name__c};
                
                for(String fieldName:fieldsNames){
                    query += ',' + fieldName; 
                }

                Map<String, Object> bindMap = new Map<String, Object>{'recordId' => recordId};

                Sobject record = 
                Database.queryWithBinds(query,
                                        bindMap, 
                                        AccessLevel.USER_MODE);
                
                if(record != null){
                    
                    req.key = credentials.API_Key__c;
                    req.days = numOfDays;
                    
                    for(String fieldName : fieldsNames){
                        req.q += fieldsNames.indexOf(fieldName) == fieldsNames.size() - 1 ? fieldName : fieldName + ',';
                    }
                    

                    ExternalService.WeatherAPI.getForecast_Response   res = service.getForecast(req);
                    ExternalService.WeatherAPI_ForecastResponse forecast = res.Code200; 
                    
                    System.debug('### res =  ' + forecast.forecast.forecastday[0].day.condition);
                    
                }
                
            }

            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}