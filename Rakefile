require 'json'

def ec2_ids
  JSON.parse(File.read('./ec2.json'))['ids']
end

namespace :ec2 do
  task :show do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'describe-instance-status', '--include-all-instances', '--instance-ids', *ec2_ids
  end

  task :start do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'start-instances', '--instance-ids', *ec2_ids
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'wait', 'instance-running', '--instance-ids', *ec2_ids
    Rake::Task['ec2:hosts'].invoke
  end

  task :stop do
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'stop-instances', '--instance-ids', *ec2_ids
    sh 'envchain', 'aws-personal', 'aws', 'ec2', 'wait', 'instance-stopped', '--instance-ids', *ec2_ids
  end

  task :hosts do
    json = JSON.parse(`envchain aws-personal aws ec2 describe-instances --instance-ids #{ec2_ids.join(" ")}`)
    puts "--- hosts ---"
    json['Reservations'].each.with_index do |r, idx|
      instance = r['Instances'][0]
      puts "#{instance['PublicIpAddress']} isucon9-#{idx + 1}"
    end
  end

  task :dumpid do
    result = chdir 'terraform' do
      JSON.parse(`envchain aws-personal terraform show -json`)
    end
    json = {}
    json['ids'] = result['values']['root_module']['resources'].filter do |resource|
      resource['name'] == 'isucon' && resource['type'] == 'aws_instance'
    end.map do |resource|
      resource['values']['id']
    end
    File.write('./ec2.json', json.to_json)
    sh 'cat', 'ec2.json'
  end
end
