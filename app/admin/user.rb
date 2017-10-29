ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :email, :password, :password_confirmation
index do
  selectable_column
  id_column
  column :name
  column :email
  column :created_at
  column :updated_at
  actions
end
#
# or
#
filter :name
filter :email

form do |f|
  f.inputs do
    f.input :name
    f.input :email
    f.input :password
    f.input :password_confirmation
  end
  f.actions
end
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

end
