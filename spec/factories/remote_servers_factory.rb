FactoryGirl.define do
  factory :remote_server do
    factory :test_remote_server_1 do
      host "host_prueba_1"
    end
    
    factory :test_remote_server_2 do
      host "host_prueba_2"
    end
    
    factory :test_remote_server_3 do
      host "host_prueba_3"
    end
  end
end