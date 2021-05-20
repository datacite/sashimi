class AttachmentParser
  def initialize(json_string)
    @attachment = JSON.parse(json_string)
  end

  def uuid
    @attachment.dig("report", "id") || ""
  end

  def header
    @attachment.dig("report", "report-header") || []
  end

  def datasets
    @attachment.dig("report", "report-datasets") || []
  end

  def subsets
    @attachment.dig("report", "report-subsets") || []
  end

  def count_subsets
    subsets = @attachment.dig("report", "report-subsets")
    subsets.nil? || subsets.empty? ? 0 : subsets.count
  end

  def search_subsets(checksum:)
    subsets = @attachment.dig("report", "report-subsets")
    return nil if subsets.nil? || subsets.empty?

    subsets.select { | subset | subset["checksum"] == checksum }.first
  end

  def find_subset(checksum)
    subsets = @attachment.dig("report", "report-subsets")
    return nil if subsets.nil? || subsets.empty?

    subsets.find { | subset | subset["checksum"] == checksum }
  end

  def subset_checksum(subset:)
    return nil if subset.nil? || subset.empty?

    subset.dig("checksum") || ""
  end

  def subset_gzip(subset:)
    return nil if subset.nil? || subset.empty?

    subset.dig("gzip") || ""
  end

  def subset_compressed(subset:)
    return nil if subset.nil? || subset.empty?

    ::Base64.strict_decode64(subset.fetch("gzip", nil))
  end
end
