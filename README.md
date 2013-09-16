nopents
=======

Node OpenTSDB Client

Installation
------------

```bash
npm install nopents
```

Usage
-----

```javascript
Nopents = require('nopents')

client = new Nopents({
  host: 'localhost',
  port: 8125
});

client.send([
  {
    key: 'my.data.point',
    val: 53,
    tags: {
      source: 'wind',
      hostname: 'thor'
    }
  }
]);
```
