require 'spec_helper'

describe 'grub' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'grub.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:user => :undef,
      #:password => :undef,
      #:protect_boot => false,
      #:protect_advanced => false,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('grub') }
        it do
          is_expected.to contain_exec('update_grub').with(
            'command' => '/usr/sbin/update-grub',
            'refreshonly' => true
          )
        end
        it { is_expected.to contain_file('/etc/default').with_ensure('directory') }
        it do
          is_expected.to contain_file('/etc/default/grub').with(
            'ensure' => 'present',
            'notify' => 'Exec[update_grub]'
          ).with_content(
            %r{GRUB_CMDLINE_LINUX="rootdelay=90 apparmor=0 console=tty0 console=ttyS1,115200n8"}
          ).with_content(
            %r{GRUB_TERMINAL="serial"}
          ).with_content(
            %r{GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=1 --word=8 --parity=no --stop=1"}
          ).without_content(
            %r{GRUB_CMDLINE_LINUX="apparmor=0"}
          ).without_content(
            %r{GRUB_TERMINAL="console"}
          )
        end
        it do
          is_expected.to contain_file('/etc/grub.d/10_linux').with(
            'ensure' => 'present',
            'mode' => '0755',
            'notify' => 'Exec[update_grub]'
          ).without_content(
            %r{GRUB_PROTECT_BOOT=""}
          ).with_content(
            %r{GRUB_PROTECT_BOOT="--unrestricted"}
          ).without_content(
            %r{GRUB_PROTECT_ADVANCED=""}
          ).with_content(
            %r{GRUB_PROTECT_ADVANCED="--unrestricted"}
          )
        end
        it do
          is_expected.to contain_file('/etc/grub.d/01_superuser').with(
            'ensure' => 'absent',
            'notify' => 'Exec[update_grub]'
          )
        end
      end
      describe 'Change Defaults' do
        context 'virtual' do
          let(:facts) { facts.merge!(virtual: 'vmware') }
          it do
            is_expected.to contain_file('/etc/default/grub').with(
              'ensure' => 'present',
              'notify' => 'Exec[update_grub]'
            ).without_content(
              %r{GRUB_CMDLINE_LINUX="rootdelay=90 apparmor=0 console=tty0 console=ttyS1,115200n8"}
            ).without_content(
              %r{GRUB_TERMINAL="serial"}
            ).without_content(
              %r{GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=1 --word=8 --parity=no --stop=1"}
            ).with_content(
              %r{GRUB_CMDLINE_LINUX="apparmor=0"}
            ).with_content(
              %r{GRUB_TERMINAL="console"}
            )
          end
        end
        context 'user' do
          before { params.merge!(user: 'username') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/grub.d/01_superuser').with_ensure(
              'absent'
            )
          end
        end
        context 'password' do
          before { params.merge!(password: 'XXXchangemeXXX') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/grub.d/01_superuser').with_ensure(
              'absent'
            )
          end
        end
        context 'user and password' do
          before { params.merge!(user: 'username', password: 'password') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/grub.d/01_superuser').with(
              'ensure' => 'present',
              'mode' => '0755',
              'notify' => 'Exec[update_grub]'
            ).with_content(
              %r{/bin/cat << EOF}
            ).with_content(
              %r{set superusers="username"}
            ).with_content(
              %r{password_pbkdf2 username password}
            ).with_content(
              %r{export superusers}
            ).with_content(
              %r{EOF}
            )
          end
        end
        context 'protect_boot' do
          before { params.merge!(protect_boot: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/grub.d/10_linux').with(
              'ensure' => 'present',
              'mode' => '0755',
              'notify' => 'Exec[update_grub]'
            ).with_content(
              %r{GRUB_PROTECT_BOOT=""}
            ).without_content(
              %r{GRUB_PROTECT_BOOT="--unrestricted"}
            )
          end
        end
        context 'protect_advanced' do
          before { params.merge!(protect_advanced: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/grub.d/10_linux').with(
              'ensure' => 'present',
              'mode' => '0755',
              'notify' => 'Exec[update_grub]'
            ).with_content(
              %r{GRUB_PROTECT_ADVANCED=""}
            ).without_content(
              %r{GRUB_PROTECT_ADVANCED="--unrestricted"}
            )
          end
        end
      end
      describe 'check bad type' do
        context 'user' do
          before { params.merge!(user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'password' do
          before { params.merge!(password: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'protect_boot' do
          before { params.merge!(protect_boot: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'protect_advanced' do
          before { params.merge!(protect_advanced: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
