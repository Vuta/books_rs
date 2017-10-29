ActiveAdmin.register Genre do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name

index do
  selectable_column
  id_column
  column :name
  column :created_at
  column :updated_at
  actions
end
#
# or
#
filter :name
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

end
