public with sharing class WeatherForecastService {

    @AuraEnabled
    public static String getForecastImperative(Id recordId, Integer numOfDays) {

        try {
            String sObjectType = String.valueOf(recordId.getSObjectType());

            Record_Weather_Location_Fields__mdt mapping = getMapping(recordId);
            if (mapping == null) return error('Missing metadata mapping for ' + sObjectType);
            Coordinates coords = getCoordinates(recordId, mapping, sObjectType);

            if (coords == null || coords.lat == null || coords.lon == null) {
                return error('Record has no coordinates');
            }

            String endpoint = buildEndpoint(coords, numOfDays);
            HttpResponse res = performCallout(endpoint);

            if (res == null) return error('No response from weather service');
            
            if (res.getStatusCode() != 200) {
                return error('HTTP ' + res.getStatusCode() + ': ' + res.getStatus());
            }

            WeatherForcastModel model = deserializeTyped(res);

            normalizeInvalidIdentifiers(model, res);
            
            orderForecastDays(model);
            
            model.status = 'OK';
            
            return  JSON.serialize(model);

        } catch (Exception e) {
            return error(e.getMessage());
        }
    }


    
    private static Record_Weather_Location_Fields__mdt getMapping(Id recordId) {
        return Record_Weather_Location_Fields__mdt.getInstance(String.valueOf(recordId.getSObjectType()));
    
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getMappingFields(Id recordId){
        Record_Weather_Location_Fields__mdt mdt = Record_Weather_Location_Fields__mdt.getInstance(String.valueOf(recordId.getSobjectType()));
        return new List<String> {mdt.Latitude_Field_Api_Name__c,mdt.Longitude_Field_Api_Name__c};
        

    }

    

    private class Coordinates {
        public String lat;
        public String lon;
        public Coordinates(String lat, String lon) {
            this.lat = lat; this.lon = lon;
        }
    }

    private static Coordinates getCoordinates(Id recordId, Record_Weather_Location_Fields__mdt m, String sObjectType) {
        
        SObject rec = fetchRecordWithCoordinates(recordId, m, sObjectType);
        
        if (rec == null) return null;
        
        String lat = String.valueOf(rec.get(m.Latitude_Field_Api_Name__c));
        String lon = String.valueOf(rec.get(m.Longitude_Field_Api_Name__c));
        
        return new Coordinates(lat, lon);
    }

    private static SObject fetchRecordWithCoordinates(Id recordId, Record_Weather_Location_Fields__mdt m, String sObjectType) {
        
        String soql = 'SELECT Id,' + m.Latitude_Field_Api_Name__c + ',' + m.Longitude_Field_Api_Name__c +
                      ' FROM ' + sObjectType + ' WHERE Id = :recordId';
        
        return Database.queryWithBinds(soql, new Map<String,Object>{ 'recordId' => recordId }, AccessLevel.USER_MODE);
    }


    private static String buildEndpoint(Coordinates c, Integer numOfDays) {
        String q = c.lat + ',' + c.lon;
        String apiKey = Callouts_Credentials__c.getValues('WeatherAPI').API_Key__c;

        return 'callout:Weather_API/v1/forecast.json?key=' + apiKey +
               '&q=' + EncodingUtil.urlEncode(q, 'UTF-8') +
               '&days=' + String.valueOf(numOfDays);
    }

    private static HttpResponse performCallout(String endpoint) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(10000);

        return new Http().send(req);
    }


    private static WeatherForcastModel deserializeTyped(HttpResponse res) {
        return (WeatherForcastModel) JSON.deserialize(res.getBody(), WeatherForcastModel.class);
    }

    private static void normalizeInvalidIdentifiers(WeatherForcastModel model, HttpResponse res) {

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        if (body == null) return;

        Map<String, Object> forecastMap = (Map<String, Object>) body.get('forecast');
        if (forecastMap == null) return;

        List<Object> rawDays = (List<Object>) forecastMap.get('forecastday');
        if (rawDays == null || model == null || model.forecast == null || model.forecast.forecastday == null) return;

        Map<String, WeatherForcastModel.ForecastDay> epochDateToForecastMap = new Map<String, WeatherForcastModel.ForecastDay>();
        
        for (WeatherForcastModel.ForecastDay d : model.forecast.forecastday) {
            epochDateToForecastMap.put(String.valueOf(d.date_epoch), d);
        }

        for (Object o : rawDays) {
            Map<String, Object> fd = (Map<String, Object>) o;
            String epochStr = String.valueOf(fd.get('date_epoch'));
            if (!epochDateToForecastMap.containsKey(epochStr)) continue;

            WeatherForcastModel.ForecastDay tgt = epochDateToForecastMap.get(epochStr);
            tgt.forecastDate = (String) fd.get('date');

            Map<String, Object> day = (Map<String, Object>) fd.get('day');
            if (day != null && tgt.day != null) {
                tgt.day.maxtemp    = (Double) day.get('maxtemp_c');
                tgt.day.mintemp    = (Double) day.get('mintemp_c');
                tgt.day.maxwind    = (Double) day.get('maxwind_mph');
                tgt.day.avghumidity= (Integer) day.get('avghumidity');
            }
        }
    }


    private class ForecastDayEpochComparator implements System.Comparator<WeatherForcastModel.ForecastDay> {

        public Integer compare(WeatherForcastModel.ForecastDay a, WeatherForcastModel.ForecastDay b) {

            if (a == null && b == null) return 0;
            if (a == null) return -1;
            if (b == null) return 1;

            if (a.date_epoch == b.date_epoch) return 0;
            return a.date_epoch > b.date_epoch ? 1 : -1;
        }
    }

    private static void orderForecastDays(WeatherForcastModel model) {

        if (model == null || model.forecast == null || model.forecast.forecastday == null) return;

        model.forecast.forecastday.sort(new WeatherForecastService.ForecastDayEpochComparator());

    }


    private static String error(String msg) {

        WeatherForcastModel m = new WeatherForcastModel();
        m.status  = 'ERROR';
        m.message = msg;
        return JSON.serialize(m);
    }

}
