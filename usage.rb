#!/usr/bin/ruby

load 'jpg2pdf.rb'

tag_info = {
  name: 'TaYaK',
  year: '2017-2018',
  prop: 'deneme',
  exam_type: 'Final',
  lesson: 'at yetistiriciligi'
}

quality = '200k'
prefix = 'Resim ('
suffix = ')'

j = Jpg2Pdf.new tag_info, quality: quality, prefix: prefix, suffix: suffix
pdf_name = j.convert 25
system "xdg-open #{pdf_name} &"