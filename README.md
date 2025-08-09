# Weather Forecasting LWC – Assignment Notes

This repository contains my Salesforce home assignment implementation for showing **tomorrow’s weather** on a record page.


## Key Points in My Approach

1. **Generic & Reusable Design**  
   - The weather forecasting component is **generic** and works with **any SObject**.  
   - This is achieved through **Custom Metadata** mapping each SObject to its location fields.  
   - When I build components or write code, I aim for **maximum reusability** so they can support other entities and use cases.  
   - Since the demand did not specify a particular SObject, I made sure the solution wouldn’t be locked to one.

2. **Switch from External Services to Apex HTTP Callout**  
   - Initially, I implemented the weather API integration using **Salesforce External Services**.  
   - However, I found that **External Services are not suitable for large JSON responses** — some nested object data was missing even though it appeared in the Swagger schema.  
   - Due to this limitation, I switched to a **standard Apex HTTP callout**.  
   - The External Services implementation still exists in the org for review.

3. **Handling Invalid Apex Identifiers from the API**  
   - The API response contains keys that are **invalid identifiers in Apex** (e.g., `date`, `maxtemp__c`, `mintemp__c` — where `__c` indicates Celsius; similar keys exist with `__f` for Fahrenheit).  
   - This required me to **manually map** these keys to my model, making the service class more verbose.  
   - If the API had valid key names, the code would be **simpler and shorter**.




## How to use 
    the LWC component is already placed in Account record Page , the event which trigger its refresh is changes in the Account "ShippingAddress" Field , if you want to see other object behavior you will need to : 
1.  Place the LWC Component on the record Record Page

2.  Add new Member to Record_Weather_Location_Fields__mdt Custom metadata


## MAKE SURE YOU CHANGE ALL OF ADDRESS FIELDS , IF YOU ONLY CHANGE ONE (e.g ZipCode) AND NOT THE REST THE API WILL NOT DISPLAY A NEW LOCATION 
