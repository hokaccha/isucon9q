package 'nginx'

service 'nginx'

template '/etc/nginx/nginx.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :reload, 'service[nginx]'
end
