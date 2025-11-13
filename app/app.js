const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World from CI/CD demo!');
});

app.get('/health', (req, res) => {
  // You can add real checks here (DB, cache, etc.)
  res.status(200).json({ status: 'ok' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

// export for tests
module.exports = app;
