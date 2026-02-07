import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: RayTracingScene());
}

class RayTracingScene extends StatefulWidget {
  const RayTracingScene({super.key});
  @override
  State<RayTracingScene> createState() => _RayTracingSceneState();
}

class _RayTracingSceneState extends State<RayTracingScene> {
  late FlutterGlPlugin glPlugin;
  int? textureId;
  dynamic glProgram;
  dynamic vao;
  dynamic defaultFbo;
  dynamic defaultFboTex;

  dynamic resolutionLoc;
  dynamic timeLoc;

  String vs = '''
#version 300 es
in vec3 a_Position;
void main() {
    gl_Position = vec4(a_Position, 1.0);
}
''';

  // 移动端优化版：MAX_DEPTH 改成 2，阴影稍微简化
  String fs = '''
#version 300 es
precision highp float;
layout(location = 0) out vec4 fragColor;

uniform vec2 resolution;
uniform float time;

const int MAX_DEPTH = 2;      // ← 改成 2，手机不卡
const float daynightV = .25;
const float camV = .8;

struct HitInfo {
    bool isHit;
    float distance;
    vec3 position;
    vec3 normal;
    vec3 color;
};

struct Sphere {
    vec3 center;
    float radius;
    vec3 color;
    float shininess;
};

float intersectSphere(vec3 ro, vec3 rd, vec3 c, float r) {
    vec3 oc = ro - c;
    float b = dot(oc, rd);
    float c_ = dot(oc, oc) - r * r;
    float disc = b * b - c_;
    if (disc < 0.0) return -1.0;
    float t = -b - sqrt(disc);
    if (t < 0.0) t = -b + sqrt(disc);
    return t;
}

HitInfo sceneIntersect(vec3 ro, vec3 rd) {
    HitInfo hit;
    hit.isHit = false;
    hit.distance = 1e5;

    Sphere s[3];
    s[0] = Sphere(vec3(2.0*sin(-1.2*time), 0.5, -5.0 + 2.0*cos(-1.2*time)), 0.5, vec3(1.0, 0.2, 0.2), 32.0);
    s[1] = Sphere(vec3(3.5, 0.0, -5.0), 0.6 + 0.015*time, vec3(0.2, 0.8, 0.2), 32.0);
    s[2] = Sphere(vec3(0.0, 1.0*sin(11.4*time) + 1.0, -5.0), 1.0, vec3(0.2, 0.3, 1.0), 32.0);

    for (int i = 0; i < 3; i++) {
        float t = intersectSphere(ro, rd, s[i].center, s[i].radius);
        if (t > 0.001 && t < hit.distance) {
            hit.isHit = true;
            hit.distance = t;
            hit.position = ro + rd * t;
            hit.normal = normalize(hit.position - s[i].center);
            hit.color = s[i].color;
        }
    }

    // 地面
    float tPlane = (-1.0 - ro.y) / rd.y;
    if (tPlane > 0.001 && tPlane < hit.distance && abs(ro.x + rd.x * tPlane) < 30.0 && abs(ro.z + rd.z * tPlane) < 30.0) {
        hit.isHit = true;
        hit.distance = tPlane;
        hit.position = ro + rd * tPlane;
        hit.normal = vec3(0.0, 1.0, 0.0);
        float pat = mod(floor(hit.position.x) + floor(hit.position.z), 2.0);
        hit.color = pat > 0.5 ? vec3(0.6) : vec3(0.02);
    }

    return hit;
}

vec3 lighting(vec3 pos, vec3 n, vec3 col, vec3 viewDir) {
    vec3 lightPos = vec3(10.0*sin(daynightV*time), 10.0*cos(daynightV*time), 0.0);
    vec3 l = normalize(lightPos - pos);
    vec3 r = reflect(-l, n);

    float diff = max(dot(n, l), 0.0);
    float spec = pow(max(dot(viewDir, r), 0.0), 64.0);

    // 简单阴影（移动端开全阴影太卡）
    float shadow = 1.0;
    if (dot(n, l) > 0.0) {
        HitInfo sh = sceneIntersect(pos + n*0.001, l);
        if (sh.isHit && sh.distance < length(lightPos - pos)) shadow = 0.5;
    }

    return col * (0.12 + diff * shadow) + vec3(0.5) * spec * shadow;
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);

    float h = 2.0 + sin(camV*time*0.5)*1.5;
    vec3 camPos = vec3(8.0*sin(camV*time*0.7), h, 8.0*cos(camV*time*0.7));
    vec3 target = vec3(0.0, 0.0, -5.0);

    vec3 f = normalize(target - camPos);
    vec3 r = normalize(cross(vec3(0.0,1.0,0.0), f));
    vec3 u = cross(f, r);

    vec3 rd = normalize(f*1.3 + r*uv.x + u*uv.y);

    vec3 color = vec3(0.0);
    vec3 throughput = vec3(1.0);
    vec3 ro = camPos;

    for (int bounce = 0; bounce < MAX_DEPTH; bounce++) {
        HitInfo hit = sceneIntersect(ro, rd);

        if (!hit.isHit) {
            vec3 sky = vec3(0.15*uv.x + 0.5*cos(daynightV*time), 0.08*uv.y, 0.3*sin(daynightV*time));
            color += throughput * sky;
            break;
        }

        vec3 shaded = lighting(hit.position, hit.normal, hit.color, -rd);
        color += throughput * shaded;

        ro = hit.position + hit.normal*0.001;
        rd = reflect(rd, hit.normal);
        throughput *= 0.45;

        if (length(throughput) < 0.05) break;
    }

    fragColor = vec4(color, 1.0);
}
''';

  double? side;
  double dpr = 1.0;
  bool isInitialized = false;
  Timer? timer; // 改成可空，避免 late 初始化问题

  //
  num time = 0.0;
  num dt = 0.016;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initGl() async {
    if (side != null) return;

    final mq = MediaQuery.of(context);
    // 让它随屏幕宽度自适应，最大不超过 600（移动端太高会卡死）
    side = mq.size.width.clamp(100.0, 600.0);
    dpr = mq.devicePixelRatio;

    glPlugin = FlutterGlPlugin();

    await glPlugin.initialize(
      options: {
        'antialias': true,
        'alpha': false,
        'width': side!.toInt(),
        'height': side!.toInt(),
        'dpr': dpr, // ← 这里修正
      },
    );

    textureId = glPlugin.textureId;

    await Future.delayed(const Duration(milliseconds: 100));
    await _setupGl();

    if (mounted) {
      setState(() => isInitialized = true);
      // 60 FPS（16ms），但手机上可以接受
      timer = Timer.periodic(
        Duration(milliseconds: (dt * 1000).toInt()),
        (_) => _render(glPlugin.gl),
      );
      print(timer?.isActive);
    }
  }

  Future<void> _setupGl() async {
    final gl = glPlugin.gl;

    if (!kIsWeb) {
      await glPlugin.prepareContext();
      _createDefaultFBO(gl);
    }

    if (!_compileProgram(gl, vs, fs)) return;

    resolutionLoc = gl.getUniformLocation(glProgram, "resolution");
    timeLoc = gl.getUniformLocation(glProgram, "time");

    _uploadVertices(gl);
  }

  void _createDefaultFBO(dynamic gl) {
    final int w = (side! * dpr).toInt();
    defaultFbo = gl.createFramebuffer();
    defaultFboTex = gl.createTexture();
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, defaultFboTex);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      w,
      w,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      null,
    );
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.bindFramebuffer(gl.FRAMEBUFFER, defaultFbo);
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      defaultFboTex,
      0,
    );
  }

  bool _compileProgram(dynamic gl, String vsSrc, String fsSrc) {
    final vs = _compileShader(gl, vsSrc, gl.VERTEX_SHADER);
    final fs = _compileShader(gl, fsSrc, gl.FRAGMENT_SHADER);
    if (vs == null || fs == null) return false;

    glProgram = gl.createProgram();
    gl.attachShader(glProgram, vs);
    gl.attachShader(glProgram, fs);
    gl.linkProgram(glProgram);

    if (gl.getProgramParameter(glProgram, gl.LINK_STATUS) == 0) {
      debugPrint('Link error: ${gl.getProgramInfoLog(glProgram)}');
      return false;
    }
    gl.useProgram(glProgram);
    return true;
  }

  dynamic _compileShader(dynamic gl, String src, int type) {
    final shader = gl.createShader(type);
    gl.shaderSource(shader, src);
    gl.compileShader(shader);
    if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0) {
      debugPrint('Shader error: ${gl.getShaderInfoLog(shader)}');
      return null;
    }
    return shader;
  }

  void _uploadVertices(dynamic gl) {
    final vertices = Float32List.fromList([
      -1.0,
      -1.0,
      0.0,
      3.0,
      -1.0,
      0.0,
      -1.0,
      3.0,
      0.0,
    ]);

    vao = gl.createVertexArray();
    gl.bindVertexArray(vao);

    final buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(
      gl.ARRAY_BUFFER,
      vertices.lengthInBytes,
      vertices,
      gl.STATIC_DRAW,
    );

    final loc = gl.getAttribLocation(glProgram, "a_Position");
    gl.vertexAttribPointer(loc, 3, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(loc);
  }

  void _render(gl) {
    /*
    print(0);
    */
    //_compileProgram(gl, vs, fs);

    time += dt;

    if (!isInitialized) return;
    final gl = glPlugin.gl;
    final int sz = (side! * dpr).toInt();

    gl.viewport(0, 0, sz, sz);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(glProgram);
    gl.uniform2f(resolutionLoc, sz.toDouble(), sz.toDouble());

    var myTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    //print(time);
    gl.uniform1f(timeLoc, time);

    gl.drawArrays(gl.TRIANGLES, 0, 3);
    gl.finish();

    glPlugin.updateTexture(defaultFboTex);
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initGl());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            color: Colors.black,
            child: isInitialized && textureId != null
                ? _glView()
                : const CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _glView() {
    return kIsWeb
        ? HtmlElementView(viewType: textureId!.toString())
        : Texture(textureId: textureId!);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
