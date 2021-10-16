public with sharing class PruebaTecnicaVuelingRestServiceCTRL {
    
    public static String insertNewShipment(String jsonString) {
        
        EnviosWrapper enviosWrap = new EnviosWrapper();
        ResponseWrapper responseWrapper = new ResponseWrapper();
        
        try {
        
        	enviosWrap = getDeserializedJSON( jsonString );
            Set<String> setProductId = new Set<String>();
            Map<String,EnviosData> mapEnvios = new Map<String,EnviosData>();
            
            
            if ( !enviosWrap.envios.isEmpty() ) {
                
                for ( EnviosData envioItem : enviosWrap.envios ) {
                    setProductId.add( envioItem.id_producto );
                    mapEnvios.put( envioItem.id_producto, envioItem );
                }
                
                Map<String, Product2> existingProducts = new Map<String, Product2>();
                existingProducts = getExistingProductsMapByProductId( setProductId );
                
                List<Envio__c> listEnviosToInsert = new List<Envio__c>();
 				List<Product2> listProductsToCreate = new List<Product2>();
                
                for ( EnviosData envioItem : mapEnvios.values() ) {

                	Product2 productFromMap = existingProducts.get( envioItem.id_producto ); 
                        
                    if ( productFromMap != null ) {
                        
                        listEnviosToInsert.add( createEnvios( productFromMap, envioItem ) );
                        
                    } else {
                        
                        Product2 newProduct = new Product2(
                        	Name = envioItem.id_producto
                        );                    	
                        
                        listProductsToCreate.add( newProduct );
                        
                    }	
                }
                
                if( !listProductsToCreate.isEmpty() && Envio__c.SObjectType.getDescribe().isAccessible() ) {

                    Database.insert( listProductsToCreate );
                    User logisticsDirector = getLogisticsDirector();
                    sendToApprovalProcess( listProductsToCreate, logisticsDirector );
                	listEnviosToInsert.addAll( createEnvios( listProductsToCreate, mapEnvios ) );     

                }
                
                if( !listEnviosToInsert.isEmpty() && Envio__c.SObjectType.getDescribe().isAccessible()) {
					Database.insert( listEnviosToInsert );
                }
            }
            
        } catch( Exception ex ) {
        	responseWrapper = new ResponseWrapper( PruebaTecnicaVuelingConstants.RESPONSE_CODE_500, ex.getMessage() + ex.getLineNumber());
        	return JSON.serialize( responseWrapper );
        }
        
        responseWrapper = new ResponseWrapper( PruebaTecnicaVuelingConstants.RESPONSE_CODE_200, null );
        
    	return JSON.serialize( responseWrapper ); 
    }
    
    private static List<Envio__c> createEnvios( List<Product2> listProductsToCreate, Map<String,EnviosData> mapEnvios ) {     
        
        List<Envio__c> listEnvios = new List<Envio__c>();
        
        for( Product2 product : listProductsToCreate ){
        	EnviosData envioItem = mapEnvios.get( product.Name );
            if( envioItem != null ){
            	listEnvios.add( createEnvios( product, envioItem ) );	   
            }
        }
        
        return listEnvios;
        
    }
    
    private static Envio__c createEnvios( Product2 product, EnviosData envioItem ) {    
        Envio__c newEnvio = new Envio__c(
            Fecha_Envio__c = date.valueOf( envioItem.fecha_envio ),
            Id_producto__c = product.Id,
            Descripcion__c = envioItem.descripcion_Producto,
            Cantidad__c = envioItem.cantidad,
            Almacen__c =  envioItem.almacen_Destino
        );
        return newEnvio;
    }
    
    private static void sendToApprovalProcess( List<Product2> listProductsToApprove, User userToSendApproval ) {
    	
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        for( Product2 productToProcess : listProductsToApprove ) {
            
        	Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest(); 
            approvalRequest.setComments( PruebaTecnicaVuelingConstants.APPROVAL_MSG + productToProcess.Name );
            approvalRequest.setObjectId( productToProcess.Id );
            approvalRequest.setSubmitterId( userToSendApproval.Id );  
            
            requests.add( approvalRequest );
            
        }        
 		
        if( !requests.isEmpty() ) {
        	Approval.process( requests );    
        }       
    }
    
    private static EnviosWrapper getDeserializedJSON( String jsonString ) {    
    	return ( EnviosWrapper ) JSON.deserialize( jsonString, EnviosWrapper.class );
    }
    
    private static User getLogisticsDirector(){  
        List<User> userLogisticsDirector = [ SELECT Id FROM User WHERE Email =: System.Label.LogisticsDirector WITH SECURITY_ENFORCED LIMIT 1 ];
        return userLogisticsDirector[0];  
    }
    
    private static Map<String, Product2> getExistingProductsMapByProductId( Set<String> setProductId ) {
    	
    	List<Product2> listExistingProducts = [ SELECT ID, Name FROM Product2 WHERE Name IN: setProductId WITH SECURITY_ENFORCED ];
        
        Map<String, Product2> mapExistingProducts = new Map<String, Product2>();
        
        for ( Product2 existingProduct : listExistingProducts ) {
        	mapExistingProducts.put( existingProduct.Name, existingProduct );  
        }
        
        return mapExistingProducts;
    }
        
    public class EnviosWrapper {
		
        public List<EnviosData> envios { get; set; }

    }
        
    public class EnviosData {
		
        public List<EnviosData> envios { get; set; }
        public String fecha_envio { get; set; }
        public String id_producto { get; set; }
        public String descripcion_Producto { get; set; }
       	public Integer cantidad { get; set; }
        public String almacen_Destino { get; set; }

    }

    public class ResponseWrapper {
		
        public ResponseWrapper(){
        }
        
        public ResponseWrapper( String responseCode, String responseMsg ){
            this.responseCode = responseCode;
            this.responseMsg = responseMsg;
        }
        
        public String responseCode { get; set; }
        public String responseMsg { get; set; }

    }
    
}