class Vtiger
  require "rubygems"
  require "httparty"

def self.get_address_from_rut(rut)

    user_name = 'grupo4'
    user_key = 'cHjPQ6N4cB87PR1D'
    url1 = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php'
    #consulta = HTTParty.get(url1+'?operation=getchallenge&username='+user_name)
    consulta = HTTParty.get(url1,:query => {"operation" => "getchallenge","username" => user_name})
    token = consulta["result"]["token"]
    
    md5 = Digest::MD5.hexdigest(token+user_key)
    
    #consulta2 = HTTParty.post(url1+'?operation=login&username='+user_name+'&accessKey='+md5)
    consulta2 = HTTParty.post(url1,:query => {"operation" => "login","username" => user_name,"accessKey" => md5})
    puts consulta
    puts token
    puts md5
    puts consulta2


  end
end