#!/usr/bin/ruby

# jpg to pdf converter class
class Jpg2Pdf
  require 'prawn'
  require 'fastimage'
  require 'logger'

  attr_writer :prefix, :suffix, :pdf_name, :quality, :infos

  YEAR = :year
  PROP = :prop
  EXAM    = :exam_type
  LESSON  = :lesson
  STUDENT = :name

  def initialize(infos,
                 prefix: '',
                 suffix: '',
                 quality: '500k')
    @infos = infos
    @prefix = prefix
    @suffix = suffix
    @quality = quality
    file = create_file_name
    @pdf_name = file + '.pdf'
    @log = Logger.new('log_' + file + '.txt')
    @log.level = Logger::INFO
  end

  def create_file_name
    @infos[LESSON].downcase.split.join('_') + '_' +
      @infos[YEAR].downcase.split('-').inject('') { |sum, n| sum + n[-2..-1] } + '_' +
      @infos[PROP].downcase.split.join('_')
  end

  def all_images_name
    "#{@prefix}*#{@suffix}.[jJ][pP][gG]"
  end

  def sorted_all_images_name
    Dir.glob(all_images_name).sort_by { |s| s[/\d+/].to_i }
  end

  def optimize_images
    @log.info 'jpegoptim optimization start...'
    if system "jpegoptim --size=#{@quality} #{all_images_name} >/dev/null"
      @log.info 'jpegoptim optimization finish with success!'
    else
      @log.error 'jpegoptim fault!'
    end
  end

  def images_supported?(image_names)
    @log.info 'Image format control start...'

    image_names.each do |im|
      unless FastImage.type im
        @log.error "#{im} unsupported format!"
        return false
      end
    end
    @log.info 'Image format control finish...'
    true
  end

  def rotate_all(images)
    @log.info 'Rotate start...'

    images.each do |im|
      sizes = FastImage.size im

      unless sizes[1] > sizes[0]
        @log.info "#{im} rotating..."
        system "convert #{im} -rotate 90 #{im}"
      end
    end
    @log.info 'Rotate finish!'
  end

  # generate pdf from sorted images array
  def generate_pdf(images,
                   text_location,
                   year: @infos[YEAR],
                   name: @infos[STUDENT],
                   lesson: @infos[LESSON],
                   exam_type: @infos[EXAM])
    @log.info 'Pdf generate start...'
    # TODO: omu dökümantasyon ilk sayfaya resim şeklinde eklenecek
    # TODO: unicode desteği ekle
    begin
      Prawn::Document.generate(@pdf_name, page_size: @pdf_sizes, margin: 0) do
        bounding_box([0, text_location], width: bounds.width, height: bounds.height, font: 'TTimesb.ttf') do
          text lesson, align: :center, size: 300
          move_down 50
          text year, align: :center, size: 250
          move_down 50
          text exam_type, align: :center, size: 200
          move_down 50
          text name, align: :center, size: 250
        end
        images.each do |img|
          start_new_page
          image img, at: [0, @pdf_sizes[-1]]
        end
      end
      @log.info 'Pdf generation finish with success!'
      true
    rescue StandardError
      @log.error 'Pdf generation fault!'
      false
    end
  end

  # check is hash ok
  def control_infos
    @log.info 'Info control started!'
    return false unless @infos.class == Hash

    props = [YEAR, PROP, LESSON, STUDENT, EXAM]
    return false unless props.sort == @infos.keys.sort
    @log.info 'Info control succesful!'
    true
  end

  def convert(start_location = 35)
    @log.info 'Convert start...'
    image_names = sorted_all_images_name
    return false unless image_names
    return false unless images_supported? image_names

    optimize_images if @quality
    rotate_all image_names

    return false unless control_infos

    @pdf_sizes = FastImage.size image_names[0]
    location = @pdf_sizes[1] - @pdf_sizes[1] * (start_location.to_i / 100.0)

    generate_pdf image_names, location
    @log.info 'Convert finish...'
    @pdf_name
  end
end

tag_info = {
  name: 'Taha Yasir',
  year: '2018-2019',
  prop: 'Vize notlari denemesi',
  exam_type: 'Vize',
  lesson: 'At yetistiriciligi'
}

j = Jpg2Pdf.new tag_info, quality: '400k'

pdf_name = j.convert
system "xdg-open #{pdf_name} &"
