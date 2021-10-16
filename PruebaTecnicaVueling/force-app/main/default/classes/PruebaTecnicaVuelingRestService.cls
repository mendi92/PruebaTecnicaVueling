@RestResource(urlMapping='/v1/saveEnvio/')
global with sharing class PruebaTecnicaVuelingRestService {
  
  	@HttpPost
    //Since we will be adding entities to Envios__c we will use POST
    global static String doPost() {
        
      String jsonString = RestContext.request.requestBody.toString();
      
      return PruebaTecnicaVuelingRestServiceCTRL.insertNewShipment(jsonString);
          
    }    
}