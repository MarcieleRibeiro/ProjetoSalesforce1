public class AccountTriggerHandler extends TriggerHandler {

    public static void validateDoc(List<Account> accountList){
        for(Account accountRecord : accountList){
            if(String.isNotBlank(accountRecord.Cpf__c)){
                String text = accountRecord.Cpf__c;
                String validate = getFormattedDocPF(text);
                
                if(validate == null){
                    accountRecord.Cpf__c.addError('CPF inválido. ');
                }else {
                    accountRecord.Cpf__c = validate;    
                }
            }
            
            if(String.isNotBlank(accountRecord.Cnpj__c)){
                String tex = accountRecord.Cnpj__c;
                String valida = getFormattedDocPJ(tex); 
                
                if(valida == null){
                    accountRecord.Cnpj__c.addError('CNPJ inválido. ');
                }else {
                    accountRecord.Cnpj__c = valida;   
                }
            }

            Account oldAcc = (Account) Trigger.oldMap.get(accountRecord.Id);
            
            if (String.isNotBlank(accountRecord.BillingPostalCode)  && accountRecord.BillingPostalCode != oldAcc.BillingPostalCode ){
                String BillingPostalCode = getzipcodeformatting(accountRecord.BillingPostalCode);
                
                if(BillingPostalCode == null){
                    accountRecord.BillingPostalCode.addError('CEP Inválido.');
                }else{
                    getAndPersistBillingAddress(accountRecord.Id, accountRecord.BillingPostalCode);
                }
            }

            if (String.isNotBlank(accountRecord.ShippingPostalCode) && accountRecord.ShippingPostalCode != oldAcc.ShippingPostalCode ){
                String ShippingPostalCode = getzipcodeformatting(accountRecord.ShippingPostalCode);
                
                if(ShippingPostalCode == null){
                    accountRecord.ShippingPostalCode.addError('CEP Inválido.');
                }else{
                    getAndPersistShippingAddress(accountRecord.Id, accountRecord.ShippingPostalCode);
                }
            }
        }
    }

    @future(callout=true)
    private static void getAndPersistShippingAddress(String accountId, String cep){
        ViaCepService.ViaCepResponse response;
        
        try {
            response = ViaCepService.viaCep(cep);
            
            Account acc = new Account();
            acc.Id = accountId;
            acc.ShippingPostalCode = cep;
            acc.ShippingStreet = response.logradouro;
            acc.ShippingCity = response.localidade;
            acc.ShippingState = response.uf;
            acc.ShippingCountry =  'Brasil';
            update acc;

        } catch (Exception e) {
            System.debug('Falha na integração do CEP: ' + e.getMessage());
        }
    }
    
    @future(callout=true)
    private static void getAndPersistBillingAddress(String accountId, String cep){
        ViaCepService.ViaCepResponse response;
        
        try {
            response = ViaCepService.viaCep(cep);

            Account acc = new Account();
            acc.Id = accountId;
            acc.BillingPostalCode = cep;
            acc.BillingStreet = response.logradouro;
            acc.BillingCity = response.localidade;
            acc.BillingState = response.uf;
            acc.BillingCountry =  'Brasil';
            update acc;

        } catch (Exception e) {
            System.debug('Falha na integração do CEP: ' + e.getMessage());
        }
    }

    public static String getFormattedDocPF(String docNumber){
        String numberOnly = getOnlyNumber(docNumber);
        Boolean isCPF = ValidateCPFCNPJ.isCPF(numberOnly);
        if(isCPF){
           return ValidateCPFCNPJ.imprimeCPF(numberOnly);  
        } else {
            return null;
        }
    }
        
    public static String getFormattedDocPJ(String docNumber){
        String numberOnly = getOnlyNumber(docNumber);
         Boolean isCNPJ = ValidateCPFCNPJ.isCNPJ(numberOnly);
         if(isCNPJ){
             return ValidateCPFCNPJ.imprimeCNPJ(numberOnly);
    	 } else {
            return null;
        }  
	}
    
    public static String getFormattedDocCepZipcode(String documentNumber){     
        String docformatted;
    	docformatted = documentNumber.substring(0,5) + '-' +  documentNumber.substring(5,8);
    	return docformatted;
    }
    
    public static String getzipcodeformatting(String docNumber){  
         String numberOnly = getOnlyNumber(docNumber);
         if (numberOnly.length() == 8){
        	return getFormattedDocCepZipcode(numberOnly);
         }else{           
             return null;
 		}  
	}
    
    public static String getOnlyNumber(String docNumber){
        if(String.isBlank(docNumber)) return null;
        String text = docNumber.replaceAll('[^0-9]','');  
        return text;
    }

    /***************************************
    * Events 	
    ***************************************/
    
    protected override void beforeInsert() {
        validateDoc(Trigger.new);
    }

    protected override void beforeUpdate() {
        validateDoc(Trigger.new);
    }

    protected override void afterUpdate() {
    }

    protected override void afterInsert() {
    }
}