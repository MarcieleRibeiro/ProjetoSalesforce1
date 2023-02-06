public class ViaCepService {

    public static ViaCepResponse viaCep(String cep){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://viacep.com.br/ws/' + cep + '/json/');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        ViaCepResponse viaCepResponse;
        if(response.getStatusCode() == 200){
            String body = response.getBody();
            viaCepResponse = (ViaCepResponse) JSON.deserialize(body, ViaCepResponse.class);
        }else{
            throw new ViaCepServiceException('Erro ao buscar CEP: ' + response.getStatusCode() + ' | ' + response.getBody());
        }
        System.debug('viaCepResponse: ' + viaCepResponse);
        return ViaCepResponse;
    }
    
    public class ViaCepResponse{
        public String cep;
        public String logradouro;
        public String bairro;
        public String localidade;
        public String uf;
        public String ddd;
        public String erro;
    }

    public virtual class ViaCepServiceException extends Exception {}
}