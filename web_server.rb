require "sinatra"
require "sinatra/flash"
require "erb"
require "active_record"
require_relative "utils/opml_export"
require_relative "utils/opml_import"

enable :sessions

# class App < Sinatra::Application

    class Task < ActiveRecord::Base
    end

    class Response < ActiveRecord::Base
    end

    get "/" do
        template = ERB.new(File.open("templates/index.html").read)

        template_content = template.result(binding)

        template_content
    end

    post "/import" do
        channel = params[:channel]
        microsub_url = params[:microsub_url]
        access_token = params[:access_token]
        opml_text = params[:opml_text]

        if channel.nil? || microsub_url.nil? || access_token.nil? || opml_text.nil?
            flash[:message] = "Please fill out all fields."
            redirect "/"
        end

        Task.establish_connection(
            :database => "tasks.db",
            :adapter => "sqlite3",
        )

        Task.create(microsub_url: microsub_url, channel: channel)

        message = import_feeds(channel, microsub_url, access_token)

        flash[:message] = message
        redirect "/"
    end

    post "/export" do
        channel = params[:channel]
        microsub_url = params[:microsub_url]
        access_token = params[:access_token]

        if microsub_url.nil? || access_token.nil? || channel.nil?
            flash[:message] = "Please fill out all fields."
            redirect "/"
        end

        message, response = export_to_opml(channel, microsub_url, access_token)

        response = response.strip

        puts response

        content_type "text/xml"

        return response
    end

    get "/task/:id" do
        Task.establish_connection(
            :database => "tasks",
            :adapter => "sqlite3",
        )

        Response.establish_connection(
            :database => "responses",
            :adapter => "sqlite3",
        )

        task = Task.find(params[:id])

        if task.nil?
            abort(404)
        end

        template = ERB.new(File.open("templates/task.html").read)

        @responses = Response.where(task_id: task.id)

        template_content = template.result(binding)

        template_content
    end

    get "/static/styles.css" do
        content_type "text/css"
        return File.read("static/styles.css")
    end

    get "/favicon.ico" do
        content_type "image/x-icon"
        return File.read("static/favicon.ico")
    end

    not_found do
        template = ERB.new(File.open("templates/404.html")).read

        template_content = template.result(binding)

        template_content
    end
    
    error 500 do
        template = ERB.new(File.open("templates/404.html")).read

        template_content = template.result(binding)

        template_content
    end
# end