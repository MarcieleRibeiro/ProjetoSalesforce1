@isTest
global class ViaCepServiceTest implements HttpCalloutMock {

    public static final String MOCK_CEP = '{"cep":"05847-620","logradouro":"Rua Yoshimara Minamoto","complemento":"","bairro":"Jardim Brasília","localidade":"São Paulo","uf":"SP","ibge":"3550308","gia":"1004","ddd":"11","siafi":"7107"}';

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(MOCK_CEP);
        response.setStatusCode(200);
        return response; 
    }    

    @isTest 
    static void viaCepTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ViaCepServiceTest());

        ViaCepService.ViaCepResponse response = ViaCepService.viaCep('05847-620');
        System.assert(response != null);
    }
}
