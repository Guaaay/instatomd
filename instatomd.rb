# nethttp2.rb
require 'uri'
require 'net/http'
require 'json'

puts("https://api.instagram.com/oauth/authorize?client_id=362181706042374&redirect_uri=https://al.astudillo.com/&scope=user_profile,user_media&response_type=code")

puts("Pega el código obtenido en el URL al que redirige la autenticación:")
code = gets
code = code.chomp

puts("Pega aquí el secreto de la app:")
client_secret = gets
client_secret = client_secret.chomp
#Exchange code for token

uri = URI('https://api.instagram.com/oauth/access_token')
res = Net::HTTP.post_form(uri, 'client_id' => '362181706042374', 'client_secret' => client_secret, 'grant_type' => 'authorization_code',
                                'redirect_uri' => 'https://al.astudillo.com/', 'code' => code)

if res.is_a?(Net::HTTPSuccess)
    token_hash = JSON.parse(res.body)
else
    puts("Ha habido un error generando el token de acceso")
    exit
end
#puts("acces_token = #{token_hash['access_token']} ")
#puts("user_id = #{token_hash['user_id']}")

uri = URI('https://graph.instagram.com/me/media')
params = { :fields => 'media_type,media_url,children{media_url,media_type},caption,timestamp', :access_token => token_hash['access_token'] }
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
if res.is_a?(Net::HTTPSuccess)
    posts_data = JSON.parse(res.body)
else
    puts("Ha habido un error obteniendo los posts")
    exit
end

post_list = posts_data['data']

#puts(res.body)
i = 0
for post in post_list
    multi = false
    puts "POST #{i}:  " + "\n\n"
    desc = post['caption']
    date = post['timestamp']
    date = date.split('T')[0].strip
    desc = desc.split('ººº')
    title = desc[0].strip.gsub(" ", "-")
    unless desc[1].nil?
        content = desc[1].strip
    else
        content = ""
    end

    puts "date: #{date} "
    single_media = post['media_url']
    children = post['children']
    file_name = "posts/#{date}-#{title}.md"
    title = title.gsub("-", " ")
    File.write(file_name, 
        "---\n" +
        "layout: post\n" +
        "title: #{title}\n" +
        "---\n")
    
    unless(children.nil?)
        child_data = children['data']
        for child in child_data
            File.write(file_name, "![#{title}](#{child['media_url']})", mode: 'a')
        end
    else
        File.write(file_name, "![#{title}](#{single_media})", mode: 'a')
    end
    File.write(file_name, content + "\n", mode: 'a')
    i = i + 1
    puts "\n\n"
end
