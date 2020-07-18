service 'nginx'

file '/etc/mysql/mysql.conf.d/mysqld.cnf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[mysql]'
end
