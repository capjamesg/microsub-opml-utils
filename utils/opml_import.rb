require "nokogiri"
require "httparty"
require "dotenv"
require "active_record"

class Response < ActiveRecord::Base
end

def import_feeds(channel, microsub_url, access_token, file_name=nil, file_contents=nil, task_id=nil)
    if !file_name.nil?
        opml_file = File.open(file_name)

        opml_xml = Nokogiri::XML(opml_file)
    elsif file_contents
        opml_xml = Nokogiri::XML(file_contents)
    else
        raise "No file name or contents provided"
    end

    feeds = []

    outlines = opml_xml.xpath("//outline")

    for line in outlines
        url = line.attribute("xmlUrl")

        if !url.nil?
            feeds.append(line.attribute("xmlUrl"))
        end
    end

    response_params = "?action=follow&channel=" + channel + "&url="

    if task_id != nil
        Response.establish_connection(
            :database => "tasks.db",
            :adapter => "sqlite3",
        )
    end

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

        if task_id != nil
            Response.create(task_id: task_id, feed_url: feed_url, response_code: req.code)
        end
    end
end

if __FILE__ == $0
    Dotenv.load

    arguments = {}

    for i in 0 ... ARGV.length
        if ARGV[i].start_with?("--")
            arguments[ARGV[i].gsub("--", "")] = ARGV[i+1]
        end
    end

    if arguments["file"].nil?
        file_name = "opml.xml"
    else
        file_name = arguments["file"]
    end

    if arguments["channel"].nil?
        puts "Please specify a channel whose feeds you want to export."
    end

    microsub_url = ENV["MICROSUB_URL"]
    access_token = ENV["MICROSUB_ACCESS_TOKEN"]

    message = import_feeds(arguments["channel"], microsub_url, access_token, file_name)

    import_feeds(file_name)
end