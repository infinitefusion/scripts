class ContactsAppLocationButton < PokenavButton
  def get_height
    return 40
  end

  def get_width
    return 200  # match your x_gap roughly
  end

  def get_text
    return @id.to_s  # location name is passed as id
  end
end
