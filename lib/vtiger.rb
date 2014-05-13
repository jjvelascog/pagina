class Vtiger

  def self.get_address_from_rut(rut)
    #Primero solicitamos token a API Vtiger
    user_name = 'grupo4'
    token = JSON.parse((RestClient.get 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=getchallenge&username=grupo4').body)['result']['token']
    url = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=login'
    md5 = Digest::MD5.hexdigest(token+'cHjPQ6N4cB87PR1D')
    #Encriptamos token recibido + accessKey y recibimos sessionId después del login
    response = RestClient.post url, 
         'operation' => 'login',
         'username' => user_name,
         'accessKey' => md5         
    sessionid= JSON.parse(response.body)['result']['sessionName']
    #query = URI.encode('SELECT accountname, cf_705 FROM Accounts;')  
    #query = URI.encode("SELECT accountname FROM Accounts WHERE cf_705='#{rut}';") 

    #Finalmente realizamos una query para obtener la dirección de un cliente de rut #.
    query = URI.encode("SELECT accountname,bill_street,bill_state  FROM Accounts WHERE cf_705='#{rut}';") 
    jsonaddress = JSON.parse(RestClient.get 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=query&sessionName='+sessionid+'&query='+query)
    address= jsonaddress['result'][0]['accountname']+', '+ jsonaddress['result'][0]['bill_street']+', '+ jsonaddress['result'][0]['bill_state']
    return address
  end
end