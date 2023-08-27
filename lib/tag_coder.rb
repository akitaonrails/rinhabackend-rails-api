class TagCoder
  def self.dump(array)
    array.join(" ")
  end

  def self.load(string)
    string.split(" ") unless string.blank?
  end
end
