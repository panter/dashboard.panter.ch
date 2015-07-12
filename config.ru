require 'dotenv'
Dotenv.load

require 'dashing'

configure do
  set :auth_token, '025a30fac3dcd9bdd10f66cc3c56aa40858230d344cfe1becd8228f4c3ce3f379cb2ab98dfdad3c0b498443f3a0b6aad66400cb3e06f7f0df36d855adb05f7f2'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
