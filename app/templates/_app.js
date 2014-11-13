var express    = require('express');
var request    = require('request');
var httpProxy  = require('http-proxy');
var CONFIG     = require('config');
var handlebars = require('express-handlebars');
var s3Policy   = require('./server/s3');
var sm         = require('sitemap');

var port    = process.env.PORT || <%= devPort %>;
var app     = express();

// env setup
if (process.env.NODE_ENV === 'development') {
  app.use(require('connect-livereload')());
  require('protractor-ci').initRecorder();
}

if (!process.env.DIST_DIR) {
  process.env.DIST_DIR = 'dist-' + process.env.NODE_ENV
}


// sitemap
sitemap = sm.createSitemap({
  hostname: CONFIG.SITE_DOMAIN,
  cacheTime: 600000,
  urls: [
   { url: '/', changefreq: 'monthly', priority: 0.9 }
  ]
});

app.get('/sitemap.xml', function(req, res) {
  sitemap.toXML(function(xml) {
    res.header('Content-Type', 'application/xml');
    res.send(xml);
  });
});


// proxy api requests (for older IE browsers)
app.all('/proxy/*', function(req, res, next) {
  // transform request URL into remote URL
  var apiUrl = 'http:'+CONFIG.API_URL+req.params[0];
  var r = null;

  // preserve GET params
  if (req._parsedUrl.search) {
    apiUrl += req._parsedUrl.search;
  }

  // handle POST / PUT
  if (req.method === 'POST' || req.method === 'PUT') {
    r = request[req.method.toLowerCase()]({uri: apiUrl, json: req.body});
  } else {
    r = request(apiUrl);
  }

  // pipe request to remote API
  req.pipe(r).pipe(res);
});

// provide s3 policy for direct uploads
app.get('/policy/:fname', function(req, res) {
  var fname       = req.params.fname;
  var contentType = 'image/png';
  var acl         = 'public-read';
  var uploadDir   = CONFIG.aws_upload_dir;

  var policy = s3Policy({
    expiration: "2014-12-01T12:00:00.000Z",
    dir:        uploadDir,
    bucket:     CONFIG.aws_bucket,
    secret:     CONFIG.aws_secret,
    key:        CONFIG.aws_key,
    acl:        acl,
    type:       contentType
  });

  res.send({
    policy: policy,
    path:   "//"+CONFIG.aws_bucket+".s3.amazonaws.com/"+uploadDir+fname,
    action: "//"+CONFIG.aws_bucket+".s3.amazonaws.com/"
  });
});

// redirect to push state url (i.e. /blog -> /#/blog)
app.get(/^(\/[^#\.]+)$/, function(req, res) {
  var path = req.url

  // preserve GET params
  if (req._parsedUrl.search) {
    path += req._parsedUrl.search;
  }

  res.redirect('/#'+path);
});

app.get('/', function(req, res) {
  res.render('index', {
    domain: req.headers.host.split(':')[0].split('.')[0],
    layout: false
  });
});

// use handlebar templates for html files
app.engine('.html', handlebars({extname: '.html'}))
app.set('views', __dirname + '/' + process.env.DIST_DIR)
app.set('view engine', '.html')

app.use(express.static(__dirname + '/' + process.env.DIST_DIR));
app.listen(port);
