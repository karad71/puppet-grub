# == Class: grub
#
class grub (
  Optional[String]  $user              = undef,
  Optional[String]  $password          = undef,
  Boolean           $protect_boot      = false,
  Boolean           $protect_advanced  = false,
  Boolean           $enable_iommu      = false,
  Boolean           $enable_huge_pages = false,
  Optional[Integer] $num_huge_pages    = undef,
) {
  exec {'update_grub':
    command     => '/usr/sbin/update-grub',
    refreshonly => true,
  }
  $_huge_page_line = "default_hugepagesz=1G hugepagesz=1G hugepages=$num_huge_pages"
  file {'/etc/default/grub':
    ensure  => present,
    content => template('grub/etc/default/grub.erb'),
    notify  => Exec['update_grub'],
  }
  file {'/etc/grub.d/10_linux':
    ensure  => present,
    mode    => '0755',
    content => template('grub/etc/grub.d/10_linux.erb'),
    notify  => Exec['update_grub'],
  }
  if $user and $password {
    file { '/etc/grub.d/01_superuser':
      ensure  => present,
      mode    => '0755',
      content => "/bin/cat << EOF\nset superusers=\"${user}\"\npassword_pbkdf2 ${user} ${password}\nexport superusers\nEOF\n",
      notify  => Exec['update_grub'],
    }
  } else {
    file { '/etc/grub.d/01_superuser':
      ensure => absent,
      notify => Exec['update_grub'],
    }
  }
}
