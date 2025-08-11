@IsTest
public with sharing class WeatherForecastServiceTest {
    
    @TestSetup
    static void makeData(){
        
        Account acc           = new Account();
        
        acc.Name              = 'Test Acc';
        acc.ShippingLatitude  = 32.0853;
        acc.ShippingLongitude = 34.7818;

        Callouts_Credentials__c credentials = new Callouts_Credentials__c();
        credentials.API_Key__c              = '123';
        credentials.Name                    = 'WeatherAPI';

        insert credentials;
        insert acc;   

        
        Opportunity opp = new Opportunity();
        opp.StageName   = 'New';
        opp.Probability = 12;
        opp.AccountId   = acc.Id;
        opp.CloseDate   = Date.today();
        opp.Name        = 'Test OPP';
        insert opp;

    }

    @IsTest
    static void testServiceOK(){
        
        Test.setMock(HttpCalloutMock.class, new MockCalloutWeatherForecastService());
        Test.startTest();
            Account acc               = [SELECT Id FROM Account LIMIT 1];
            WeatherForcastModel model = (WeatherForcastModel) JSON.deserializeStrict(WeatherForecastService.getForecastImperative(acc.Id, 1),WeatherForcastModel.class);
            System.assertEquals(2, model.forecast.forecastday.size());
            System.assertEquals('OK', model.status);
        Test.stopTest();
    }


    @IsTest
    static void testServiceERROR(){
        
        Test.setMock(HttpCalloutMock.class, new MockCalloutWeatherForecastService());
        Test.startTest();
            Opportunity opp           = [SELECT Id FROM Opportunity LIMIT 1];
            WeatherForcastModel model = (WeatherForcastModel) JSON.deserializeStrict(WeatherForecastService.getForecastImperative(opp.Id, 1),WeatherForcastModel.class);
            System.assertEquals('ERROR', model.status);
        Test.stopTest();
    }


    @IsTest
    static void testGetFieldMapping(){
        
        Test.startTest();
            
            Account acc                  = [SELECT Id FROM Account LIMIT 1];
            List<String>  fieldsNames    = WeatherForecastService.getMappingFields(acc.Id); 

            System.assertEquals('ShippingLatitude', fieldsNames[0]);
            System.assertEquals('ShippingLongitude', fieldsNames[1]);

        Test.stopTest();
    }

    @IsTest
    static void testServerError(){
        
        Test.setMock(HttpCalloutMock.class, new MockBadRequestWeatherForService());
        Test.startTest();
            
            Account acc                  = [SELECT Id FROM Account LIMIT 1];
            WeatherForcastModel model    = (WeatherForcastModel) JSON.deserializeStrict(WeatherForecastService.getForecastImperative(acc.Id, 1),WeatherForcastModel.class);
            System.assertEquals('ERROR', model.status);
            System.assertEquals(true, model.message.contains('HTTP'));
        Test.stopTest(); 
    }
}