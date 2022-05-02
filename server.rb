# frozen_string_literal:true

require 'socket'
require 'json'

HTML = "#{File.dirname(__FILE__)}/index.html"
STYLE = "#{File.dirname(__FILE__)}/style.css"
BOOTSTRAP = "#{File.dirname(__FILE__)}/bootstrap.min.css"
new_message = false

server = TCPServer.new('0.0.0.0', 5000)
while (connection = server.accept)
  request = connection.gets
  next if request.nil?

  method, path = request.split(' ')

  def send_message(conn, mess)
    conn.print "HTTP/1.1 200 OK\r\n"
    conn.print "Content-Type: text/html;charset=utf-8\r\n"
    conn.print "\r\n"
    conn.print mess
    conn.close
  end

  case path
  when '/'
    send_message(connection, File.read(HTML))
  when '/style.css'
    send_message(connection, File.read(STYLE))
  when '/bootstrap.min.css'
    send_message(connection, File.read(BOOTSTRAP))
  when '/chat'
    if method == 'POST'
      headers = {}
      while (line = connection.gets.split(' ', 2))
        break if line[0] == ''

        headers[line[0].chomp(':')] = line[1].strip
      end
      message = JSON.parse(connection.read(headers['Content-Length'].to_i))
      new_message = true
      send_message(connection, 'message received succesfully')
      next
    end
    if method == 'GET' && new_message == true
      send_message(connection, "[#{Time.now.strftime('%T')}] #{message['u']}: #{message['m']}")
      new_message = false
      next
    end
    send_message(connection, 'no new messages')
  end
end
