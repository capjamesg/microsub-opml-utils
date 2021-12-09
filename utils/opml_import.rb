require "nokogiri"
require "httparty"
require "dotenv"

def import_feeds(file_name)
    opml_file = File.open(file_name)

    opml_xml = Nokogiri::XML(opml_file)

    feeds = []

    outlines = opml_xml.xpath("//outline")

    for line in outlines
        url = line.attribute("xmlUrl")

        if !url.nil?
            feeds.append(line.attribute("xmlUrl"))
        end
    end

    response_params = "?action=follow&channel=" + channel + "&url="

    for feed in feeds
        data = {
            "action" => "follow",
            "channel" => channel,
            "url" => feed
        }

        req = HTTParty.post(
            microsub_url + response_params + feed,
            :headers => { "Authorization" => "Bearer #{access_token}" },
            :body => data
        )

        if req.code == 200
            puts "Added #{feed}"
        else
            puts "Error adding #{feed} (Status Code: #{req.code})"
        end
    end
end

if __FILE__ == $0
    Dotenv.load

    arguments = {}

    for i in 0 ... ARGV.length
        if ARGV[i].start_with("--")
            arguments[ARGV[i].to_sym.replace("--", "")] = ARGV[i+1]
        end
    end

    if arguments[:file].nil?
        file_name = "opml.xml"
    else
        file_name = arguments[:file]
    end

    if !arguments[:channel].nil?
        puts "Please specify a channel whose feeds you want to export."
    end

    microsub_url = ENV["MICROSUB_URL"]
    access_token = ENV["MICROSUB_ACCESS_TOKEN"]

    message = import_feeds(channel, microsub_url, access_token)

    import_feeds(file_name)
end