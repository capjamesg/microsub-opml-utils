require "nokogiri"
require "httparty"
require "dotenv"

def export_to_opml(channel, microsub_url, access_token, file_name=nil)
    # get a list of feeds in a channel
    get_microsub_feeds = HTTParty.get(
        microsub_url + "?action=follow&channel=" + channel,
        :headers => { "Authorization" => "Bearer #{access_token}" }
    )

    if get_microsub_feeds.code != 200
        return "ERROR: The microsub endpoint returned a #{get_microsub_feeds.code} status code."
    end

    # create opml structure
    opml_file_text = %(
    <?xml version="1.0" encoding="UTF-8"?>
    <opml version="1.0">
        <head>
            <title>Feed Export from Microsub Reader</title>
        </head>
        <body>
    )

    # add individual feed items to opml file
    for item in get_microsub_feeds["items"]
        if item["title"]
            opml_file_text += "\t<outline text=\"" + item["name"] + "\" xmlUrl=\"" + item["url"] + "\"/>\n"
        else
            opml_file_text += "\t<outline text=\"" + item["url"] + "\" xmlUrl=\"" + item["url"] + "\"/>\n"
        end
    end

    # close file with end tags
    opml_file_text += %(
        </body>
    </opml>
    )

    if file_name != nil
        File.open(file_name, "w") { |file| file.write(opml_file_text) }
    end

    return "Feeds were successfuly exported to #{file_name}.", opml_file_text
end

if __FILE__ == $0
    Dotenv.load

    arguments = {}

    for i in 0 ... ARGV.length
        if ARGV[i].start_with?("--")
            arguments[ARGV[i].gsub("--", "")] = ARGV[i+1]
        end
    end

    if !arguments["file_name"]
        file_name = "opml.xml"
    else
        file_name = arguments["file_name"]
    end

    if !arguments["channel"]
        puts "Please specify a channel whose feeds you want to export."
        exit
    end

    microsub_url = ENV["MICROSUB_URL"]
    access_token = ENV["MICROSUB_ACCESS_TOKEN"]

    message, response = export_to_opml(arguments["channel"], microsub_url, access_token, file_name)

    puts message
end