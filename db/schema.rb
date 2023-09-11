# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_27_015102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "pessoas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "apelido", limit: 32, null: false
    t.string "nome", limit: 100, null: false
    t.datetime "nascimento"
    t.string "stack"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :text, as: "(((((nome)::text || ' '::text) || (apelido)::text) || ' '::text) || (COALESCE(stack, ' '::character varying))::text)", stored: true
    t.index ["apelido"], name: "index_pessoas_on_apelido", unique: true
    t.index ["searchable"], name: "index_pessoas_on_searchable", opclass: :gist_trgm_ops, using: :gist
  end

end
