# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
begin
  require 'rspec/core/rake_task'

  namespace :tests do
    desc "Run all RSpec tests"
    RSpec::Core::RakeTask.new(:spec)

    desc "Run RSpec tests that do not require VM fixtures or a particular shell"
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = "spec/unit/**/*_spec.rb"
    end

    desc 'Run tests that require a host System Under Test configured with WinRM'
    RSpec::Core::RakeTask.new(:winrm) do |t|
      t.rspec_opts = '--tag winrm'
    end

    desc 'Run tests that require a host System Under Test configured with SSH'
    RSpec::Core::RakeTask.new(:ssh) do |t|
      t.rspec_opts = '--tag ssh'
    end

    desc 'Run tests that require a host System Under Test configured with Docker'
    RSpec::Core::RakeTask.new(:docker) do |t|
      t.rspec_opts = '--tag docker'
    end

    desc 'Run tests that require a host System Under Test configured with LXD'
    RSpec::Core::RakeTask.new(:lxd) do |t|
      t.rspec_opts = '--tag lxd_transport'
    end

    desc 'Run tests that require a host System Under Test configured with LXD remote'
    RSpec::Core::RakeTask.new(:lxd_remote) do |t|
      t.rspec_opts = '--tag lxd_remote'
    end

    desc 'Run tests that require a host System Under Test configured with Podman'
    RSpec::Core::RakeTask.new(:podman) do |t|
      t.rspec_opts = '--tag podman'
    end

    desc 'Run tests that require Bash on the local host'
    RSpec::Core::RakeTask.new(:bash) do |t|
      t.rspec_opts = '--tag bash'
    end

    desc 'Run tests that require Windows on the local host'
    RSpec::Core::RakeTask.new(:windows) do |t|
      t.rspec_opts = '--tag windows'
    end

    desc 'Run tests that require OMI docker container'
    RSpec::Core::RakeTask.new(:omi) do |t|
      t.rspec_opts = '--tag omi'
    end
  end

  # The following tasks are run during CI and require additional environment setup
  # to run. Jobs that run these tests can be viewed in .github/workflows/
  namespace :ci do
    namespace :linux do
      desc ''
      RSpec::Core::RakeTask.new(:integration) do |t|
        t.pattern = "spec/integration/**/*_spec.rb,spec/bolt_server/**/*_spec.rb,spec/bolt_spec/**/*_spec.rb"
        t.rspec_opts = '--tag ~winrm --tag ~lxd_transport --tag ~lxd_remote --tag ~winrm_agentless ' \
                        '--tag ~podman --tag ~kerberos --tag ~omi --tag ~windows_agents'
      end
    end

    namespace :windows do
      desc ''
      RSpec::Core::RakeTask.new(:agentless) do |t|
        t.pattern = "spec/integration/**/*_spec.rb,spec/bolt_spec/**/*_spec.rb"
        t.rspec_opts = '--tag winrm_agentless'
      end
      desc ''
      RSpec::Core::RakeTask.new(:integration) do |t|
        t.pattern = "spec/integration/**/*_spec.rb,spec/bolt_spec/**/*_spec.rb"
        t.rspec_opts = '--tag ~ssh --tag ~bash --tag ~podman --tag ~lxd_transport --tag ~lxd_remote ' \
                       '--tag ~docker --tag ~puppetdb --tag ~omi --tag ~winrm_agentless'
      end
    end

    desc "Run RSpec tests for Bolt's bundled content"
    task :modules do
      success = true
      # Test core modules
      Pathname.new("#{__dir__}/../bolt-modules").each_child do |mod|
        Dir.chdir(mod) do
          sh 'rake spec' do |ok, _|
            success = false unless ok
          end
        end
      end
      # Test modules
      %w[canary aggregate puppetdb_fact puppet_connect].each do |mod|
        Dir.chdir("#{__dir__}/../modules/#{mod}") do
          sh 'rake spec' do |ok, _|
            success = false unless ok
          end
        end
      end
      # Test BoltSpec
      Dir.chdir("#{__dir__}/../bolt_spec_spec/") do
        sh 'rake spec' do |ok, _|
          success = false unless ok
        end
      end
      raise "Module tests failed" unless success
    end
  end
rescue LoadError
end
# rubocop:enable Lint/SuppressedException
