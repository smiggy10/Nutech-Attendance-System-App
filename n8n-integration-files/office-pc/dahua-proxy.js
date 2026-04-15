/**
 * dahua-proxy.js
 * Listens on port 5679, decompresses Dahua's raw-deflate body,
 * then forwards plain text to n8n on port 5678.
 *
 * Fixes: "incorrect header check" and "Module zlib is disallowed"
 */

const http = require('http');
const zlib = require('zlib');

const PROXY_PORT  = 5679;          // Dahua sends events here
const N8N_HOST    = '127.0.0.1';
const N8N_PORT    = 5678;          // n8n listens here

// ── collect raw bytes from a request ──────────────────────────────────────────
function collectBuffer(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end',  () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

// ── try every decompression method, return plain Buffer ───────────────────────
function decompress(buf, encoding) {
  const enc = (encoding || '').toLowerCase().trim();

  // Attempt order: raw-deflate first (what Dahua actually sends),
  // then wrapped deflate, then gzip, then auto
  const attempts = [
    () => zlib.inflateRawSync(buf),   // Dahua raw deflate ← most likely
    () => zlib.inflateSync(buf),      // zlib-wrapped deflate
    () => zlib.gunzipSync(buf),       // gzip
    () => zlib.unzipSync(buf),        // auto-detect
  ];

  for (const fn of attempts) {
    try {
      const result = fn();
      if (result && result.length > 0) return result;
    } catch(e) {}
  }

  // Nothing worked — return original buffer as-is
  return buf;
}

// ── forward decompressed body to n8n ──────────────────────────────────────────
function forwardToN8n(req, bodyBuf, headers) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: N8N_HOST,
      port:     N8N_PORT,
      path:     req.url,
      method:   req.method,
      headers:  {
        ...headers,
        'content-length': Buffer.byteLength(bodyBuf),
        // Remove compression headers so n8n treats body as plain text
        'content-encoding': 'identity',
      },
    };

    // Clean up hop-by-hop headers
    delete options.headers['transfer-encoding'];

    const proxyReq = http.request(options, proxyRes => {
      let resp = '';
      proxyRes.on('data', c => resp += c);
      proxyRes.on('end', () => resolve({ status: proxyRes.statusCode, body: resp }));
    });

    proxyReq.on('error', reject);
    proxyReq.write(bodyBuf);
    proxyReq.end();
  });
}

// ── main server ───────────────────────────────────────────────────────────────
const server = http.createServer(async (req, res) => {
  try {
    const rawBuf  = await collectBuffer(req);
    const encoding = req.headers['content-encoding'] || '';

    let bodyBuf;
    if (encoding && encoding !== 'identity') {
      bodyBuf = decompress(rawBuf, encoding);
      console.log(`[proxy] ${req.method} ${req.url} | encoding=${encoding} | raw=${rawBuf.length}b -> decompressed=${bodyBuf.length}b`);
    } else {
      bodyBuf = rawBuf;
      console.log(`[proxy] ${req.method} ${req.url} | no compression | ${rawBuf.length}b`);
    }

    // Forward with stripped Content-Encoding
    const forwardHeaders = { ...req.headers };
    delete forwardHeaders['content-encoding'];
    forwardHeaders['content-length'] = Buffer.byteLength(bodyBuf);

    const result = await forwardToN8n(req, bodyBuf, forwardHeaders);
    console.log(`[proxy] n8n responded: ${result.status}`);

    res.writeHead(result.status || 200);
    res.end(result.body || '');

  } catch(err) {
    console.error('[proxy] error:', err.message);
    res.writeHead(502);
    res.end('Proxy error: ' + err.message);
  }
});

server.listen(PROXY_PORT, '0.0.0.0', () => {
  console.log(`[proxy] Dahua proxy listening on port ${PROXY_PORT}`);
  console.log(`[proxy] Forwarding to n8n at ${N8N_HOST}:${N8N_PORT}`);
  console.log(`[proxy] Strips Content-Encoding: deflate before forwarding`);
});
