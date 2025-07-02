part of 'server.dart';

// CORS Settings
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
};

// Swagger UI 핸들러
var swaggerUIHandler = (Request request) {
  const html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Store API Documentation</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui.css" />
  <style>
    html {
      box-sizing: border-box;
      overflow: -moz-scrollbars-vertical;
      overflow-y: scroll;
    }
    *, *:before, *:after {
      box-sizing: inherit;
    }
    body {
      margin:0;
      background: #fafafa;
    }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>

  <script src="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui-bundle.js"></script>
  <script src="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui-standalone-preset.js"></script>
  <script>
    window.onload = function() {
      const ui = SwaggerUIBundle({
        url: '/api-docs',
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout"
      });
    };
  </script>
</body>
</html>
  ''';

  return Response(
    200,
    body: html,
    headers: {'Content-Type': 'text/html'},
  );
};

var apiDocsHandler = (Request request) {
  print('API docs 요청됨');

  final paths = ['../specs/swagger.yaml', 'specs/swagger.yaml'];

  for (String path in paths) {
    final yamlFile = File(path);
    print('시도: $path');

    if (yamlFile.existsSync()) {
      print('파일 발견: $path');
      try {
        final yamlContent = yamlFile.readAsStringSync();
        return Response(
          200,
          body: yamlContent,
          headers: {
            'Content-Type': 'application/x-yaml',
            ...corsHeaders,
          },
        );
      } catch (e) {
        print('읽기 실패: $e');
      }
    }
  }

  return Response(
    404,
    body: 'Swagger YAML file not found. 현재 디렉토리: ${Directory.current.path}',
    headers: {
      'Content-Type': 'text/plain',
      ...corsHeaders,
    },
  );
};

var menuHandler = (Request request, String mallType) {
  List<Map<String, Object>> data;
  print(mallType);

  if (mallType == 'store') {
    data = storeMenus;
  } else {
    data = beautyMenus;
  }

  Map<String, dynamic> result = {
    'status': 'SUCCESS',
    'code': '0000',
    'message': '성공',
    'data': data,
  };

  return Response(
    200,
    body: jsonEncode(result),
    headers: {
      'Content-type': 'application/json',
      ...corsHeaders,
    },
  );
};

var viewModuleHandler = (Request request, String tabId, String page) {
  Map<String, dynamic> result = {
    'status': 'SUCCESS',
    'code': '0000',
    'message': '성공',
  };

  if (int.parse(page) >= 5) {
    result['data'] = [];
  } else {
    result['data'] = viewModules(
      tabId.startsWith('1', 0) ? 'store' : 'beauty',
    );
  }

  return Response(
    200,
    body: jsonEncode(result),
    headers: {
      'Content-type': 'application/json',
      ...corsHeaders,
    },
  );
};