@RestResource(urlMapping='/v1/saveEnvio/')
global with sharing class PruebaTecnicaVuelingRestService {
  
  	@HttpPost
    global static String doPost() {
        
      String jsonString = RestContext.request.requestBody.toString();
      
      return PruebaTecnicaVuelingRestServiceCTRL.insertNewShipment(jsonString);
          
    }    
}