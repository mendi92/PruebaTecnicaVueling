@isTest
public class PruebaTecnicaVuelingRSCTRLTest {
    @isTest
    public static void test200OKNewProd() { 
        
        String jsonString = '{ "envios":[{"fecha_envio":"2021-09-22","id_producto":"PRODUCTOTEST1","descripción Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
        
        Test.StartTest();
        String res = PruebaTecnicaVuelingRestServiceCTRL.insertNewShipment(jsonString);
        Test.StopTest();

        Product2 product = [SELECT Id,Name FROM Product2 WHERE NAME =: 'PRODUCTOTEST1' ];
        
        System.AssertEquals( 'PRODUCTOTEST1', product.Name );
        
        PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper responseWrapper = new PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper();
        responseWrapper = ( PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper )JSON.deserialize( res, PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper.class );
        System.AssertEquals( '200', responseWrapper.responseCode );
    }
    
    @isTest
    public static void test200OKExistingPod() {
        Product2 newProduct = new Product2(
            Name = 'testyaexiste'
        );    
    	insert newProduct;

        String jsonString2 = '{ "envios":[{"fecha_envio":"2021-09-22","id_producto":"testyaexiste","descripción Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
       
        Test.StartTest();
        String res2 = PruebaTecnicaVuelingRestServiceCTRL.insertNewShipment(jsonString2);
        Test.StopTest();

        Product2 product = [SELECT Id,Name FROM Product2 WHERE NAME =: 'testyaexiste' ];

        System.AssertEquals( 'testyaexiste', product.Name );

        PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper responseWrapper = new PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper();
        responseWrapper = ( PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper ) JSON.deserialize( res2, PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper.class );
        System.AssertEquals( '200', responseWrapper.responseCode );
    }

    @isTest
    public static void test500KO(){
         //JSON malformed
         String jsonString3 = '{ "envios:[{"fecha_envio":"2021-09-22","id_producto":"productotest231223245","descripción Producto":"prod 1","cantidad":1,"almacen_Destino":"BCN"}  ]}';
         Test.StartTest();
         String res3 = PruebaTecnicaVuelingRestServiceCTRL.insertNewShipment(jsonString3);
         Test.StopTest();
        
         PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper responseWrapper = new PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper();
         responseWrapper = ( PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper ) JSON.deserialize( res3, PruebaTecnicaVuelingRestServiceCTRL.ResponseWrapper.class );
         System.AssertEquals( '500', responseWrapper.responseCode );
    }
}