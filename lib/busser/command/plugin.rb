# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'busser/thor'
require 'busser/command/plugin_install'
require 'busser/command/plugin_list'

module Busser

  module Command

    # Plugin commands.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Plugin < Busser::Thor::Base

      register Busser::Command::PluginInstall, "install",
        "install PLUGIN [PLUGIN ...]", "Installs one or more plugins"
      register Busser::Command::PluginList, "list",
        "list", "Lists installed plugins"
    end
  end
end