class User < ApplicationRecord
  self.table_name = 'tblSecurityUsers'

  validates_presence_of :UserName, message: 'Name is required.'
  validates_presence_of :LoginName, message: 'Username is required.'
  validates_presence_of :PasswordHash, message: 'Password is required.'
  validates_uniqueness_of :LoginName, message: 'Username is already registered.'

  def self.is_valid_password?(user_name, password)
    require 'net/ldap'
	
    ldap_args = {}
    ldap_args[:host] = LDAP_CONFIG['host']
    ldap_args[:port] = LDAP_CONFIG['port']

    auth = {}
    
    auth[:username] = "#{LDAP_CONFIG['domain']}\\#{user_name}"
    auth[:password] = password
    auth[:method] = :simple
    ldap_args[:auth] = auth
    ldap = Net::LDAP.new(ldap_args)
    base = LDAP_CONFIG['base']

    search_param = "#{user_name}"
    
    result_attrs = ["sAMAccountName", "displayName", "memberOf", "mail"]
    
    #Build filter
    search_filter = Net::LDAP::Filter.eq("sAMAccountName", search_param)
    person_filter = Net::LDAP::Filter.eq("objectClass", "person")
    composite_filter = Net::LDAP::Filter.join(search_filter, person_filter)

    begin
      if ldap.bind && !password.blank?
        ldap.search(:base => base,:filter => composite_filter, :attributes => result_attrs) do |item|
          groups = {}
          groups = item.memberOf
            #puts "#{item.sAMAccountName.first}: #{item.displayName.first} (#{item.mail.first}) #{item.memberOf}"
            #puts groups          
            groups.each do |group|
              if "#{group}" == LDAP_CONFIG['cn'] + ',' + LDAP_CONFIG['ou'] + ',' + LDAP_CONFIG['base']
                return true
              else
                return false
              end
            end
        end
      else
        false
      end
    rescue => e
      return false
    end
  end

end