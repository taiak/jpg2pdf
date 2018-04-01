#!/usr/bin/ruby

load 'jpg2pdf.rb'


# Not: resim dosyaları bu dosyayla aynı dizinde olmalıdır

# tag_info türkçe karakter girilmeden yazılmalıdır. 
# Aksi halde pdf üretilemeyecektir
tag_info = {
  name: 'TaYaK',
  year: '2017-2018',
  prop: 'deneme',
  exam_type: 'Final',
  lesson: 'at yetistiriciligi'
}

# resim kalitesi bir resim dosyasının maksimum boyutunu temsil eder
# kalite özelliği verilmeyebilir. varsayılan kullanılır
# kalite optimizasyonu istenmiyorsa
# quality = false yapılmalıdır
quality = '200k'
# "Resim (1).jpg" "Resim (2).jpg" şeklinde ilerleryen bir dizide
# sayıların öncesi prefix, sonrası suffix olarak ayarlanmalıdır
prefix = 'Resim ('
suffix = ')'

# Resim1.jpg veya 1.jpg gibi durumlarda
# ön ek veya son ek yoksa bunlar yazılmamalıdır
# örneğin 1.jpg 2.jpg şeklinde ilerleyen dosyalar için komu şu şekildedir:
# j = Jpg2Pdf.new tag_info, quality: quality

j = Jpg2Pdf.new tag_info, quality: quality, prefix: prefix, suffix: suffix

# sayfanın yüzde kaçından itibaren yazılacağını ayarlar. yazılmazsa varsayılan lçütler kullanılır
pdf_name = j.convert 25

# sistemde dönüştürülen pdf'i aç. Bu kendi kullanımım için eklediğim bir özellik
# bazı sistemlerde çalışmayabilir
# ayrıca pdf dönüştürülemesede açmayaçalışıyor
system "xdg-open #{pdf_name}"
