class ServerAccount < ApplicationRecord
	self.table_name = 'tblServerAccounts'
	attr_accessor :SystemServer, :SystemDatabase, :WebServer, :WebDatabase, :UseWindowsNT, :Username, :Password

	def self.search(search)
		if search
			where('AccountCode LIKE ?', "%#{search}%")
		else
			all
		end
	end
end
