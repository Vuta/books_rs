ActiveAdmin.register Book do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
includes :reviews, :genre

permit_params :title, :description, :author, :released_date, :publisher, :isbn, :genre_id, :cover

index do
  selectable_column
  id_column
  column :title
  column :author
  column :released_date
  column :publisher
  column :genre
  actions
end

filter :title
filter :author

form do |f|
  f.inputs do
    f.input :title
    f.input :author
    f.input :description
    f.input :released_date
    f.input :publisher
    f.input :isbn
    f.input :genre
    f.input :cover
  end
  f.actions
end
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

end
