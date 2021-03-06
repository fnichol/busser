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
require 'busser/plugin'

module Busser

  module Command

    # Setup command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Setup < Busser::Thor::BaseGroup

      class_option :type,
        :desc => "Type of binstub file to create (bourne or bat)",
        :default => "bourne"

      def perform
        banner "Setting up Busser"
        create_busser_root
        generate_busser_binstub
      end

      private

      def create_busser_root
        info "Creating BUSSER_ROOT in #{root_path}"
        empty_directory(root_path, :verbose => false)
      end

      def generate_busser_binstub
        info "Creating busser binstub"

        if options[:type] == "bat"
          generate_busser_binstub_for_bat
        else
          generate_busser_binstub_for_bourne
        end
      end

      def generate_busser_binstub_for_bat
        binstub = root_path + "bin/busser.bat"
        busser_root = root_path.to_s.gsub("/", "\\")

        File.unlink(binstub) if File.exists?(binstub)
        create_file(binstub, :verbose => false) do
          <<-BUSSER_BINSTUB.gsub(/^ {12}/, '')
            @ECHO OFF
            REM This file was generated by Busser.
            REM
            REM The application 'busser' is installed as part of a gem, and
            REM this file is here to facilitate running it.

            REM Make sure any variables we set exist only for this batch file
            SETLOCAL

            REM Set Busser Root Path
            SET "BUSSER_ROOT=#{busser_root}"

            REM Export gem paths so that we use the isolated gems.
            SET "GEM_HOME=#{gem_home}"
            SET "GEM_PATH=#{gem_path}"
            SET "GEM_CACHE=#{gem_home}\\cache"

            REM Unset RUBYOPT, we don't want this bleeding into our runtime.
            SET RUBYOPT=
            SET GEMRC=

            REM Call the actual Busser bin with our arguments
            "#{ruby_bin}" "#{gem_bindir}\\busser" %*

            REM Store the exit status so we can re-use it later
            SET "BUSSER_EXIT_STATUS=%ERRORLEVEL%"

            REM Exit with the proper exit status from Busser
            exit /b %BUSSER_EXIT_STATUS%
          BUSSER_BINSTUB
        end
      end

      def generate_busser_binstub_for_bourne
        binstub = root_path + "bin/busser"

        File.unlink(binstub) if File.exists?(binstub)
        create_file(binstub, :verbose => false) do
          <<-BUSSER_BINSTUB.gsub(/^ {12}/, '')
            #!/usr/bin/env sh
            #
            # This file was generated by Busser.
            #
            # The application 'busser' is installed as part of a gem, and
            # this file is here to facilitate running it.
            #
            if test -n "$DEBUG"; then set -x; fi

            # Set Busser Root path
            BUSSER_ROOT="#{root_path}"

            export BUSSER_ROOT

            # Export gem paths so that we use the isolated gems.
            GEM_HOME="#{gem_home}"; export GEM_HOME
            GEM_PATH="#{gem_path}"; export GEM_PATH
            GEM_CACHE="#{gem_home}/cache"; export GEM_CACHE

            # Unset RUBYOPT, we don't want this bleeding into our runtime.
            unset RUBYOPT GEMRC

            # Call the actual Busser bin with our arguments
            exec "#{ruby_bin}" "#{gem_bindir}/busser" "$@"
          BUSSER_BINSTUB
        end
        chmod(binstub, 0755, :verbose => false)
      end

      def ruby_bin
        result = if bindir = RbConfig::CONFIG["bindir"]
          File.join(bindir, "ruby")
        else
          "ruby"
        end
        result = result.gsub("/", "\\").concat(".exe") if bat?
        result
      end

      def gem_home
        Gem.paths.home.dup.tap { |p| p.gsub!("/", "\\") if bat? }
      end

      def gem_path
        Gem.paths.path.join(":").dup.tap { |p| p.gsub!("/", "\\") if bat? }
      end

      def gem_bindir
        Gem.bindir.dup.tap { |p| p.gsub!("/", "\\") if bat? }
      end

      def bat?
        options[:type] == "bat"
      end
    end
  end
end
