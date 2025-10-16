// app.js
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Mini Toolchain running!\n');
});

server.listen(3000, () => {
  console.log('Server running on http://3.110.106.248:3000');
});
