require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/puma'

set :scm, :git
set :port, '22 -A'
set :user, 'ubuntu'
set :domain, 'dlight.io'
set :deploy_to, '/home/ubuntu/dlight'
set :repository, 'git@github.com:rodrigomoya/tesape.git'
set :branch, 'master'
set :shared_paths, ['config/database.yml', 'log']
set_default :rvm_path, "/home/ubuntu/.rvm/scripts/rvm"
invoke :'rvm:use[ruby-2.3.0@default]'

task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
end

set :shared_paths, ['config/database.yml', 'tmp/pids', 'tmp/sockets']

desc 'Deploys the current version to the server.'
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    invoke :'puma:phased_restart'
  end
end