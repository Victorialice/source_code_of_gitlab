class LabelSerializer < BaseSerializer
  entity LabelEntity

  def represent_appearance(resource)
    represent(resource, { only: [:id, :title, :color, :text_color] })
  end
end
