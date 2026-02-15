// Simple Node.js Express Application
// This is the developer's actual application code

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Simple in-memory "database"
const customers = [
  { id: 1, name: 'Acme Corp', email: 'contact@acme.com' },
  { id: 2, name: 'TechStart Inc', email: 'info@techstart.com' },
  { id: 3, name: 'Global Services', email: 'hello@globalservices.com' }
];

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Routes
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Customer Portal - Platform Demo</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          max-width: 1200px;
          margin: 0 auto;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 12px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        h1 {
          color: #333;
          margin-bottom: 10px;
        }
        .subtitle {
          color: #666;
          margin-bottom: 30px;
        }
        .status {
          background: #d4edda;
          color: #155724;
          padding: 12px 20px;
          border-radius: 6px;
          border-left: 4px solid #28a745;
          margin-bottom: 30px;
        }
        .info {
          background: #f8f9fa;
          padding: 20px;
          border-radius: 8px;
          margin-bottom: 30px;
        }
        .info h3 {
          margin-top: 0;
          color: #495057;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        th, td {
          text-align: left;
          padding: 12px;
          border-bottom: 1px solid #dee2e6;
        }
        th {
          background: #f8f9fa;
          font-weight: 600;
          color: #495057;
        }
        tr:hover {
          background: #f8f9fa;
        }
        .api-links {
          margin-top: 30px;
          padding: 20px;
          background: #e7f3ff;
          border-radius: 8px;
        }
        .api-links a {
          display: inline-block;
          margin: 5px 10px 5px 0;
          padding: 8px 16px;
          background: #0066cc;
          color: white;
          text-decoration: none;
          border-radius: 4px;
          font-size: 14px;
        }
        .api-links a:hover {
          background: #0052a3;
        }
        code {
          background: #f4f4f4;
          padding: 2px 6px;
          border-radius: 3px;
          font-family: 'Courier New', monospace;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 Customer Portal</h1>
        <p class="subtitle">Deployed with Platform Team's no-code modules</p>
        
        <div class="status">
          ✅ Application is running successfully! Deployed using HCP Terraform no-code modules.
        </div>

        <div class="info">
          <h3>📊 About This Application</h3>
          <p><strong>App Name:</strong> customer-portal</p>
          <p><strong>Environment:</strong> Development</p>
          <p><strong>Region:</strong> US East</p>
          <p><strong>Developer:</strong> Application Team</p>
          <p><strong>Infrastructure:</strong> Managed by Platform Team's webserver module</p>
        </div>

        <h2>👥 Customers</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Company Name</th>
              <th>Email</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>1</td>
              <td>Acme Corp</td>
              <td>contact@acme.com</td>
            </tr>
            <tr>
              <td>2</td>
              <td>TechStart Inc</td>
              <td>info@techstart.com</td>
            </tr>
            <tr>
              <td>3</td>
              <td>Global Services</td>
              <td>hello@globalservices.com</td>
            </tr>
          </tbody>
        </table>

        <div class="api-links">
          <h3>🔌 API Endpoints</h3>
          <a href="/api/customers">GET /api/customers</a>
          <a href="/api/health">GET /api/health</a>
          <a href="/api/info">GET /api/info</a>
        </div>

        <div class="info" style="margin-top: 30px;">
          <h3>💡 How This Works</h3>
          <ol>
            <li>Developer created a simple <code>main.tf</code> with 3 variables</li>
            <li>Used platform team's <code>webserver</code> module from private registry</li>
            <li>Terraform provisioned: VPC, subnets, security groups, EC2, and more</li>
            <li>Developer deployed the Node.js app - that's it!</li>
          </ol>
          <p><strong>Result:</strong> Infrastructure in 5 minutes, no AWS expertise needed! 🎉</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// API: Get all customers
app.get('/api/customers', (req, res) => {
  res.json({
    success: true,
    count: customers.length,
    data: customers
  });
});

// API: Get single customer
app.get('/api/customers/:id', (req, res) => {
  const customer = customers.find(c => c.id === parseInt(req.params.id));
  if (!customer) {
    return res.status(404).json({ success: false, message: 'Customer not found' });
  }
  res.json({ success: true, data: customer });
});

// API: Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    application: 'customer-portal',
    environment: process.env.NODE_ENV || 'development'
  });
});

// API: Application info
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Customer Portal',
    version: '1.0.0',
    developer: 'Application Team',
    description: 'Simple customer management portal deployed with no-code Terraform modules',
    infrastructure: 'Managed by Platform Team',
    module_used: 'webserver v1.0.0',
    deployment: 'HCP Terraform + Private Registry'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Customer Portal running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`✅ Deployed using Platform Team's no-code modules`);
});
