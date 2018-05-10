# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171102063049) do

  create_table "dtproperties", primary_key: ["id", "property"], force: :cascade do |t|
  end

  create_table "tblESS", primary_key: "Id", id: :integer, force: :cascade do |t|
  end

  create_table "tblEditions", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Name", limit: 200, null: false
  end

  create_table "tblExecutables", primary_key: "Version", id: :varchar, limit: 50, default: "0", force: :cascade do |t|
    t.varchar "Name", limit: 100, null: false
    t.string "Stream"
    t.datetime "TimeStamp", null: false
  end

  create_table "tblPasswordPolicy", id: false, force: :cascade do |t|
    t.integer "EnforcePasswordHistory"
    t.integer "MaxAge"
    t.integer "MinAge"
    t.integer "MinLength"
    t.boolean "Complexity"
    t.integer "WarnDays"
    t.integer "LockOnLoginFailedAttempt", default: 0, null: false
    t.integer "LockUserAfterBeingInactiveFor", default: 0, null: false
    t.integer "InitialPasswordWillExpireAfter", default: 0, null: false
  end

  create_table "tblScripts", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Name", limit: 250, null: false
    t.datetime "Date", null: false
    t.integer "SecurityUserId", null: false
  end

  create_table "tblSecurityGroupAccess", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Code", limit: 256, null: false
    t.varchar "Description", limit: 1000
  end

  create_table "tblSecurityKeys", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "SecurityKey", limit: 1000, null: false
    t.varchar "Description", limit: 1000, null: false
    t.integer "ParentId"
    t.integer "CheckSum"
    t.boolean "Active", default: true, null: false
    t.integer "Order"
  end

  create_table "tblSecurityUserPasswordHistory", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.integer "SecurityUserId", null: false
    t.datetime "PasswordDate", null: false
    t.integer "PasswordHash", null: false
  end

  create_table "tblSecurityUserSecurityKeys", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.integer "SecurityUserId"
    t.integer "SecurityKeyId"
  end

  create_table "tblSecurityUserServerAccounts", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.integer "SecurityUserId", null: false
    t.integer "ServerAccountId", null: false
    t.index ["SecurityUserId"], name: "IX_tblSecurityUserServerAccounts_SecurityUserId"
    t.index ["ServerAccountId"], name: "IX_tblSecurityUserServerAccounts_ServerAccountId"
  end

  create_table "tblSecurityUsers", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "UserName", limit: 250, null: false
    t.varchar "LoginName", limit: 50, null: false
    t.integer "PasswordHash", null: false
    t.boolean "Active", default: true, null: false
    t.boolean "UserCanChangePassword", default: false, null: false
    t.boolean "PasswordNeverExpires", default: false, null: false
    t.datetime "PasswordDate", default: -> { "getdate()" }, null: false
    t.boolean "UserChangePasswordNextLogon", default: false, null: false
    t.integer "LoginFailedAttempts"
    t.boolean "IsLocked", default: false, null: false
    t.varchar "LockReason", limit: 250
    t.datetime "LastLogin"
    t.integer "CreatedById"
    t.datetime "CreationDate"
    t.integer "SecurityGroupAccessId"
    t.datetime "DateLocked"
    t.index ["LoginName"], name: "UX_tblSecurityUsers", unique: true
  end

  create_table "tblServerAccounts", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "AccountCode", limit: 50, null: false
    t.varchar "AccountName", limit: 50, null: false
    t.integer "SystemId", null: false
    t.varchar "Connection", null: false
    t.boolean "Active", default: true, null: false
    t.boolean "UseSystemConnectionForWeb", default: true, null: false
    t.varchar "WebConnection"
    t.varchar "ComputedWebConnection", null: false
    t.integer "CreatedById"
    t.datetime "CreationDate"
    t.boolean "IsEnableESS", default: false, null: false
  end

  create_table "tblSystems", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Code", limit: 50, null: false
    t.varchar "Name", limit: 50, null: false
    t.varchar "ConnectionPrefix", limit: 50
    t.varchar "ConnectionEncryption", limit: 50
    t.varchar "RegistryPath", limit: 50, null: false
    t.varchar "ExeName", limit: 50, null: false
    t.boolean "Active", default: true, null: false
    t.varchar "PackageExtensionName", limit: 50, null: false
  end

  create_table "tblVersionInfo", primary_key: "Version", id: :varchar, limit: 50, default: nil, force: :cascade do |t|
    t.varchar "ProductName", limit: 50
  end

  create_table "tblWebJPS", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Name", limit: 100
  end

  create_table "tblWebJPSSessions", id: :integer, force: :cascade do |t|
    t.varchar "session_id", limit: 255, null: false
    t.text_basic "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "IX_tblWebJPSSessions_session_id"
    t.index ["updated_at"], name: "IX_tblWebJPSSessions_updated_at"
  end

  create_table "tblWebkioskVersions", primary_key: "Id", id: :integer, force: :cascade do |t|
    t.varchar "Name", limit: 250, null: false
    t.boolean "IsEnableAccountRecovery", default: false, null: false
    t.varchar "BrowserTitle", limit: 500, null: false
  end

  create_table "tblsessions", id: :integer, force: :cascade do |t|
    t.varchar "session_id", limit: 255, null: false
    t.text_basic "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "IX_tblsessions_session_id"
    t.index ["updated_at"], name: "IX_tblsessions_updated_at"
  end

end
