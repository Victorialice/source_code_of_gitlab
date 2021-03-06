module Labels
  class UpdateService < Labels::BaseService
    def initialize(params = {})
      @params = params.dup.with_indifferent_access
    end

    # returns the updated label
    def execute(label)
      params[:color] = convert_color_name_to_hex if params[:color].present?

      label.update(params)
      label
    end
  end
end
