#!/usr/bin/env python3
"""
Simple HTTP server to serve Flutter web app
"""
import http.server
import socketserver
import os
import sys
from urllib.parse import urlparse

class FlutterWebHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def do_GET(self):
        # Parse the URL
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # If it's an API request, proxy to backend
        if path.startswith('/api/'):
            self.proxy_to_backend()
            return
        
        # For all other requests, serve the Flutter web app
        if path == '/' or path == '':
            path = '/index.html'
        
        # Check if file exists
        file_path = os.path.join(os.getcwd(), 'build', 'web', path.lstrip('/'))
        if os.path.exists(file_path) and os.path.isfile(file_path):
            super().do_GET()
        else:
            # For SPA routing, serve index.html
            self.path = '/index.html'
            super().do_GET()
    
    def proxy_to_backend(self):
        """Proxy API requests to the backend"""
        import urllib.request
        import urllib.parse
        
        try:
            # Remove /api prefix and forward to backend
            backend_path = self.path[4:]  # Remove '/api'
            backend_url = f"http://localhost:8000{backend_path}"
            
            # Forward the request
            req = urllib.request.Request(backend_url, method=self.command)
            
            # Copy headers
            for header, value in self.headers.items():
                if header.lower() not in ['host', 'content-length']:
                    req.add_header(header, value)
            
            # Handle request body for POST/PUT requests
            if self.command in ['POST', 'PUT', 'PATCH']:
                content_length = int(self.headers.get('Content-Length', 0))
                if content_length > 0:
                    body = self.rfile.read(content_length)
                    req.data = body
            
            # Make the request
            with urllib.request.urlopen(req) as response:
                self.send_response(response.status)
                
                # Copy response headers
                for header, value in response.headers.items():
                    if header.lower() not in ['content-encoding', 'transfer-encoding']:
                        self.send_header(header, value)
                
                self.end_headers()
                
                # Copy response body
                self.wfile.write(response.read())
                
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Proxy error: {str(e)}".encode())

def main():
    # Change to the web directory
    web_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(web_dir)
    
    # Check if build/web directory exists
    build_dir = os.path.join(web_dir, 'build', 'web')
    if not os.path.exists(build_dir):
        print("❌ Flutter web build not found!")
        print("Please run: flutter build web")
        sys.exit(1)
    
    # Change to the build/web directory
    os.chdir(build_dir)
    
    PORT = 4000
    
    print(f"🚀 Starting Flutter web server on port {PORT}")
    print(f"📁 Serving from: {os.getcwd()}")
    print(f"🌐 Web app: http://localhost:{PORT}")
    print(f"🔗 Backend API: http://localhost:8000")
    print("Press Ctrl+C to stop")
    
    with socketserver.TCPServer(("", PORT), FlutterWebHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Server stopped")

if __name__ == "__main__":
    main()
