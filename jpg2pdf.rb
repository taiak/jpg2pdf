#!/usr/bin/ruby

class Jpg2Pdf
  require 'prawn'
  require 'fastimage'
  
  attr_writer :prefix, :suffix, :quality, :pdf_name

  def initialize(prefix: '', suffix: '', pdf_name: 'pdf', quality: '300k')
    @quality  = quality
    @prefix   = prefix
    @suffix   = suffix
    @pdf_name = pdf_name
  end

  def sorted_all_images_name
    Dir.glob("#{@prefix}*#{@suffix}.jpg").sort_by { |s| s[/\d+/].to_i }
  end

  def all_images_name
    "#{@prefix}*#{@suffix}.jpg"
  end

  def optimize_images
    system "jpegoptim --size=#{@quality} #{all_images_name} >/dev/null"
  end

  def images_supported?(image_names)
    image_names.each do |im|
      return false unless FastImage.type im
    end
    true
  end

  def convert
    image_names = sorted_all_images_name
    return false unless image_names

    return false unless images_supported? image_names
    size = FastImage.size image_names.first
    `mogrify -rotate 90 *.jpg`
    begin
      Prawn::Document.generate("#{@pdf_name}.pdf", :page_size => size, :margin => 0) do
        image image_names.first, :at => [0, size[-1]]
        image_names[1..-1].each do |img|
          start_new_page
          image img, :at => [0, size[-1]]
        end
      end
      true
    rescue Exception
      puts 'Pdf\'e  dönüştürülemedi!'
      false
    end
  end
end

j = Jpg2Pdf.new suffix: '_uc', pdf_name: 'deneme'
p j.sorted_all_images_name
p j.convert
`xdg-open deneme.pdf`
