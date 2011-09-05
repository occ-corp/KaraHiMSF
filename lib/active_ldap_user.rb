# -*- coding: utf-8 -*-

# Oops!!!!
#
# Activeldap-1.2.2 does not perform with activerecord-3.0.0.
# So, we alternatively use net-ldap-0.1.1 which is used in Redmine-1.0.

class ActiveLdapUser # < ActiveLdap::Base
  # ldap_mapping :prefix => "ou=Users"

  # def self.authenticate(dn, password)
  #   user = find dn
  #   user.bind password
  #   user
  # end

  def self.authenticate2(username, password)
    Net::LDAP.new(:host => "ldap.example.com",
                  :port => "389",
                  :auth => {
                    :method => :simple,
                    :username => "uid=#{username.to_s.toutf8},ou=Users,dc=example,dc=com",
                    :password => password.to_s.toutf8,
                  }).bind
  end
end
