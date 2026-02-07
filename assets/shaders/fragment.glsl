#version 100
precision mediump float;

uniform vec2 u_resolution;   // 画布尺寸（像素）
uniform float u_time;        // 运行时间（秒）

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;   // 0~1 归一化坐标
    vec3 col = 0.5 + 0.5 * cos(u_time + uv.xyx + vec3(0,2,4));
    gl_FragColor = vec4(col, 1.0);
}