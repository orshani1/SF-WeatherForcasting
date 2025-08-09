public with sharing class WeatherForcastModel {


    public Location location {get;set;}
    public Forecast forecast {get;set;}
    
    public class Location {
        public String name     {get;set;}
        public String country  {get;set;}
        public String tz_id    {get;set;}
    }

    public class Forecast {
        public List<ForecastDay> forecastday;
    }

    public class ForecastDay{
        public String forecastDate {get;set;}
        public Integer date_epoch  {get;set;}
        public Day day            {get;set;}
    }

    public class Day{

        public Double   maxtemp    {get;set;}
        public Double   mintemp    {get;set;}
        public Double   maxwind    {get;set;}
        public Integer avghumidity {get;set;}
        public Condition condition {get;set;}
    }

    public class Condition {
        public String text {get;set;}
        public String icon {get;set;}
    }
}