class UserIndex < Chewy::Index
  index_scope User

  field :email
  field :username
  field :created_at, type: "date"
  field :updated_at, type: "date"
  field :role
  field :banned, type: "boolean"
  field :remember_created_at, type: "date"
end
