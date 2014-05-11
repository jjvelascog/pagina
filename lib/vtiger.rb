class Vtiger

def self.get_address_from_rut(rut)

    user_name = 'grupo4'
    url1 = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=getchallenge'
    token = JSON.parse(RestClient.get url1, :body => {
        username: user_name
    })['result']['token']

    url2 = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=login'
    digest_string = token+'cHjPQ6N4cB87PR1D'
    md5 = Digest::MD5.hexdigest(digest_string)
    response = RestClient.post url2, :body => {
        'operation' => 'login',
        'username' => user_name,
        'accessKey' => md5
    }



    return response
    #return "Token: " + token + " MD5: " + md5
  end
end