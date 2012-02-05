#
# Cookbook Name:: jark
# Recipe:: server
#
# Copyright 2012, Isaac Praveen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "jark"

options =  "-i #{node[:jark][:install_root]} -c #{node[:jark][:clojure_version]} "
options += "-s #{node[:jark][:server_version]} --jvm-opts #{node[:jark][:jvm_opts]} "
options += "-p #{node[:jark][:port]} "

execute "install server" do
  command "jark #{options} server install"
end

execute "start server" do
  command "jark #{options} server start"
end
