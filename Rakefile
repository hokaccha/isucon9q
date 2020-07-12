require 'json'

def ec2_ids
  JSON.parse(File.read('./ec2.json'))
end

namespace :ec2 do
  task :show do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'describe-instance-status', '--include-all-instances', '--instance-ids', *ec2_ids
  end

  task :start do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'start-instances', '--instance-ids', *ec2_ids
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'wait', 'instance-running', '--instance-ids', *ec2_ids
  end

  task :stop do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'stop-instances', '--instance-ids', *ec2_ids
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'wait', 'instance-stopped', '--instance-ids', *ec2_ids
  end
end
