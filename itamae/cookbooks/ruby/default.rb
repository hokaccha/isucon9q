package 'build-essential'
package 'zlib1g-dev'
package 'libxml2-dev'
package 'libssl-dev'
package 'libyaml-dev'

execute 'ruby-install' do
  cwd '/tmp'
  command 'git clone https://github.com/tagomoris/xbuild.git && xbuild/ruby-install 2.7.1 /usr/local'
end
