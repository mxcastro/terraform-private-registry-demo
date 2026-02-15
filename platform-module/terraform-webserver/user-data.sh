#!/bin/bash
set -e

# Update system
yum update -y

# Install common tools
yum install -y \
  git \
  htop \
  nginx \
  amazon-cloudwatch-agent

# Configure nginx
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
EOF

# Create placeholder app
mkdir -p /home/ec2-user/app
cat > /home/ec2-user/app/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>${application_name} - ${environment}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info { color: #666; margin: 20px 0; }
        .status { color: #28a745; font-weight: bold; }
        code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 ${application_name}</h1>
        <p class="status">✅ Server is running!</p>
        <div class="info">
            <p><strong>Environment:</strong> ${environment}</p>
            <p><strong>Status:</strong> Ready for deployment</p>
        </div>
        <h2>Next Steps</h2>
        <ol>
            <li>Deploy your application to <code>/home/ec2-user/app</code></li>
            <li>Configure your app to listen on port 3000</li>
            <li>Nginx will proxy requests from port 80 to your app</li>
        </ol>
        <h2>Deployment Example</h2>
        <pre><code>scp -r ./my-app ec2-user@THIS_SERVER:/home/ec2-user/app
ssh ec2-user@THIS_SERVER
cd app && npm install && npm start</code></pre>
    </div>
</body>
</html>
EOF

chown -R ec2-user:ec2-user /home/ec2-user/app

# Start and enable services
systemctl start nginx
systemctl enable nginx

# Create a simple status page
mkdir -p /usr/share/nginx/html
cp /home/ec2-user/app/index.html /usr/share/nginx/html/

echo "Web server setup complete for ${application_name} (${environment})"
