module AccessPermissions
  extend ActiveSupport::Concern

  included do
    before_action :get_resources
    before_action :set_resource, except: %i[index new create]
    before_action :deny_read_only, only: %i[edit update destroy]
  end

  private

  def get_resources
    resource_class = controller_name.classify.constantize
    @resources =
      Current.user.admin? ?
        resource_class.all :
        Current.user.send(controller_name)
    instance_variable_set("@#{controller_name}", @resources)
  end

  def set_resource
    @resource = @resources.find(params[:id])
    @read_only = @resource.permission_type != "edit"
    instance_variable_set("@#{controller_name.singularize}", @resource)
  end

  def deny_read_only
    raise ActiveRecord::RecordNotFound if @read_only
  end
end
