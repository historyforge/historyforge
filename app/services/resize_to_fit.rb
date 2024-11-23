# frozen_string_literal: true

class ResizeToFit < ApplicationInteraction
  # @!attribute [r] device
  #  @return [String]
  string :device
  # @!attribute [r] style
  #  @return [String]
  string :style

  # @return [Array<Integer>]
  def execute
    width = if style == 'full'
              case style
              when 'half'
                (width.to_f * 0.50).ceil
              when 'third'
                (width.to_f * 0.33).ceil
              when 'quarter'
                (width.to_f * 0.25).ceil
              else
                (width.to_f * (style.to_f / 100)).ceil
              end
            else
              case device
              when 'tablet'  then 1024
              when 'phone'   then 740
              else 1278
              end
            end
    [width, width * 3]
  end
end